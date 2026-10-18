#!/usr/bin/env python3
"""
Create a harmless PE-like file that contains ransomware-shaped *strings*
but no executable code. Perfect for rehearsing the full malsandbox + Wazuh pipeline.

Usage:
    python make-test-sample.py [output_path]
    Default output: lab/fake_ransom.exe
"""

import os
import sys
import struct
import hashlib

MZ_STUB = (
    b"MZ"
    + b"\x90" * 58
    + struct.pack("<I", 0x40)
    + b"PE\0\0"
    + b"\x4c\x01"
    + b"\x01\x00"
    + b"\0" * 16
)

STRINGS = b"""
Your files have been encrypted.
Your documents, photos, databases are now encrypted.
To decrypt your files you must pay the ransom in bitcoin.
Send bitcoin to the address below.
Files are encrypted with a strong algorithm.
vssadmin delete shadows /all /quiet
wbadmin delete catalog -quiet
cmd.exe /c
powershell -enc
.onion
bitcoin
CreateRemoteThread
VirtualAllocEx
WriteProcessMemory
CryptEncrypt
"""

def make_sample(path: str) -> None:
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    padding = os.urandom(3500)
    data = MZ_STUB + STRINGS + padding
    with open(path, "wb") as f:
        f.write(data)
    sha = hashlib.sha256(data).hexdigest()
    print(f"wrote {path} ({len(data)} bytes) — harmless, no executable code")
    print(f"SHA-256: {sha}")
    print("Your antivirus may quarantine it because of the ransom-note text — that is expected.")

if __name__ == "__main__":
    out = sys.argv[1] if len(sys.argv) > 1 else "lab/fake_ransom.exe"
    make_sample(out)