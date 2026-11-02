"""
Default output filename:
python3 backup_keys.py

Specify output archive:
python3 backup_keys.py ~/secure/keys_backup.zip


Restore:
unzip keys_backup.zip -d ~/key_restore
cp -r ~/key_restore/.ssh ~/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*

gpg --import ~/key_restore/gpg_export/public_keys.asc
gpg --import ~/key_restore/gpg_export/private_keys.asc
gpg --import-ownertrust ~/key_restore/gpg_export/ownertrust.txt
"""

import os
import sys
import zipfile
import subprocess
import tempfile
import shutil
from pathlib import Path
from datetime import datetime


def export_keys(output=None):
    home = Path.home()

    if output is None:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output = Path.cwd() / f"keys_backup_{timestamp}.zip"
    else:
        output = Path(output).expanduser().resolve()

    ssh_dir = home / ".ssh"
    gpg_dir = home / ".gnupg"

    # Create temporary directory for GPG exports
    with tempfile.TemporaryDirectory() as temp:
        temp_dir = Path(temp)
        gpg_export = temp_dir / "gpg"
        gpg_export.mkdir()

        # Export GPG public keys
        subprocess.run(
            ["gpg", "--armor", "--export"],
            stdout=open(gpg_export / "public_keys.asc", "wb"),
            check=True
        )

        # Export GPG private keys
        subprocess.run(
            ["gpg", "--armor", "--export-secret-keys"],
            stdout=open(gpg_export / "private_keys.asc", "wb"),
            check=True
        )

        # Export GPG ownertrust
        subprocess.run(
            ["gpg", "--export-ownertrust"],
            stdout=open(gpg_export / "ownertrust.txt", "w"),
            check=True
        )

        with zipfile.ZipFile(
            output, "w", compression=zipfile.ZIP_DEFLATED
        ) as archive:

            # Include SSH files
            if ssh_dir.exists():
                for file in ssh_dir.rglob("*"):
                    if file.is_file() and not file.is_symlink():
                        archive.write(
                            file,
                            file.relative_to(home)
                        )

            # Include GPG exports
            for file in gpg_export.iterdir():
                archive.write(
                    file,
                    f"gpg_export/{file.name}"
                )

            # Include GPG configuration
            if gpg_dir.exists():
                for name in [
                    "gpg.conf",
                    "gpg-agent.conf",
                    "dirmngr.conf"
                ]:
                    file = gpg_dir / name
                    if file.is_file():
                        archive.write(
                            file,
                            f"gnupg_config/{name}"
                        )

    # Restrict archive permissions to current user
    try:
        os.chmod(output, 0o600)
    except OSError:
        pass

    print(f"[+] Backup created: {output}")
    print("[!] Archive contains sensitive private keys.")
    print("[!] Store it in a secure location.")


if __name__ == "__main__":
    destination = sys.argv[1] if len(sys.argv) > 1 else None
    export_keys(destination)
