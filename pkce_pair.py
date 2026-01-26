import os
import base64
import hashlib
from typing import Tuple


def codes() -> Tuple[str, str]:
    """
    Generate (verifier, challenge) pair for OAuth PKCE
    """
    verifier = generate_code_verifier()
    challenge = generate_code_challenge(verifier)
    return verifier, challenge


def generate_code_verifier() -> str:
    # 32 random bytes (same as Uint8Array(32))
    random_bytes = os.urandom(32)
    return base64_url_encode(random_bytes)


def generate_code_challenge(verifier: str) -> str:
    digest = hashlib.sha256(verifier.encode("utf-8")).digest()
    return base64_url_encode(digest)


def base64_url_encode(data: bytes) -> str:
    return (
        base64.urlsafe_b64encode(data)
        .decode("utf-8")
        .rstrip("=")
    )


if __name__ == "__main__":
    print(codes())

    # Example result:
    # verifier: 'TIAObGD5Lxq-6ZiInMM_-Jbsut5oLgelqYbkLDG7T6I'
    # challenge: 'b-b7NGE4Bh7avBcHiSirYBmyDoKtnXAdmz3Ig0uX0s8'
