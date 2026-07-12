# Mirror GitLab Repository to GitHub Using SSH

This guide explains how to configure a GitLab CI/CD pipeline that mirrors the `main` branch from GitLab to GitHub using an SSH deploy key.

---

# Prerequisites

- A GitLab repository (source)
- A GitHub repository (destination)
- Owner or admin access to both repositories

---

# Step 1. Generate an SSH Key Pair

On your local machine, generate a dedicated SSH key for the CI pipeline.

```bash
ssh-keygen -t ed25519 -C "gitlab-mirror" -f gitlab-mirror-key
```

This creates:

```
gitlab-mirror-key        # Private key
gitlab-mirror-key.pub    # Public key
```

Do **not** use your personal SSH key.

---

# Step 2. Encode the Private Key

Your GitLab pipeline expects the private key to be Base64 encoded.

Linux/macOS:

```bash
base64 -w0 gitlab-mirror-key
```

If `-w0` is not supported (macOS):

```bash
base64 < gitlab-mirror-key | tr -d '\n'
```

Copy the entire output.

---

# Step 3. Add the Private Key to GitLab

Open your GitLab project.

Navigate to:

```
Settings
    CI/CD
        Variables
```

Create a new variable:

| Name | Value |
|------|-------|
| `SSH_PRIVATE_KEY_B64` | Base64-encoded private key |

Settings:

- Protected: **Yes** (if your `main` branch is protected)
- Masked: **No** (GitLab usually cannot mask multiline/Base64 SSH keys)
- Expand variable reference: **Disabled**

Save the variable.

---

# Step 4. Add the Public Key to GitHub

Open the destination GitHub repository.

Navigate to:

```
Settings
    Deploy keys
```

Click:

```
Add deploy key
```

Paste the contents of:

```text
gitlab-mirror-key.pub
```

Example:

```text
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... gitlab-mirror
```

Enable:

- ✅ Allow write access

Save the deploy key.

> The pipeline needs write access because it pushes commits to GitHub.

---

# Step 5. Verify the GitHub Repository URL

Your pipeline uses:

```text
git@github.com:shaninalex/<repository_name>.git
```

Ensure that:

- the repository exists
- the deploy key was added to **this** repository

---

# Step 6. Verify the Pipeline

Your pipeline should contain:

```yaml
before_script:
  - apk add --no-cache git openssh
  - mkdir -p ~/.ssh
  - echo "$SSH_PRIVATE_KEY_B64" | base64 -d > ~/.ssh/id_ed25519
  - chmod 600 ~/.ssh/id_ed25519
  - ssh-keyscan github.com >> ~/.ssh/known_hosts
```

This:

- installs Git and SSH
- restores the private key
- secures permissions
- trusts GitHub's host key

---

# Step 7. Push to GitLab

Commit to the `main` branch.

GitLab CI will execute:

```bash
git remote add github git@github.com:shaninalex/<repository_name>.git
git fetch --unshallow || true
git fetch --all --tags
git checkout -B main origin/main
git push --force github main:refs/heads/main
```

The latest `main` branch will be mirrored to GitHub.

---

# Step 8. Verify the Mirror

Open your GitHub repository.

You should see:

- latest commits
- tags
- updated `main` branch

---

# Troubleshooting

## Permission denied (publickey)

This usually means:

- the wrong private key is stored in GitLab
- the matching public key is not installed on GitHub
- write access was not enabled for the deploy key

---

## Repository not found

Verify the remote URL:

```text
git@github.com:shaninalex/<repository_name>.git
```

Also verify that the deploy key belongs to that repository.

---

## Host key verification failed

Ensure the pipeline contains:

```bash
ssh-keyscan github.com >> ~/.ssh/known_hosts
```

---

## Invalid Base64

Re-encode the private key:

Linux:

```bash
base64 -w0 gitlab-mirror-key
```

macOS:

```bash
base64 < gitlab-mirror-key | tr -d '\n'
```

---

# Security Notes

- Never commit the private key to the repository.
- Store only the Base64-encoded private key in GitLab CI/CD Variables.
- Only the public key should be uploaded to GitHub.
- Consider using a dedicated key for each mirrored repository.
- Protect the `SSH_PRIVATE_KEY_B64` variable so it is available only to protected branches.
