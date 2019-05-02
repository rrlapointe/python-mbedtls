import subprocess
import sys

import pytest


@pytest.mark.skipif(
    sys.version_info < (3, 6), reason="requires python3.6 or higher"
)
class TestCryptAndHash:
    def test_encrypt_decrypt(self, randbytes, tmpdir):
        infile = tmpdir.join("test.in")
        aesfile = tmpdir.join("test.aes")

        buffer = randbytes(500)
        infile.write_binary(buffer)
        enc = subprocess.run(
            [
                "programs/aes/crypt_and_hash",
                "--encrypt",
                "--key",
                "123",
                "-o",
                aesfile,
                infile,
            ],
            check=True,
        )
        assert enc.returncode == 0
        dec = subprocess.run(
            [
                "programs/aes/crypt_and_hash",
                "--decrypt",
                "--key",
                "123",
                aesfile,
            ],
            check=True,
            capture_output=True,
        )
        assert dec.returncode == 0
        assert dec.stdout == buffer
