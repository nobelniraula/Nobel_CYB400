#!/usr/bin/env bash
# Setup script for Kali Linux (or any Debian-based analysis host)
# Run from the Nobel-malsandbox-wazuh-win10 directory.

set -euo pipefail

echo "[*] Creating Python virtual environment..."
python3 -m venv .venv
source .venv/bin/activate

echo "[*] Upgrading pip..."
pip install --upgrade pip

echo "[*] Installing malsandbox (editable) with all extras..."
if [ -d "behaviour-analysis-sandbox/malsandbox" ]; then
    cd behaviour-analysis-sandbox/malsandbox
    pip install -e ".[all]"
    cd ../..
elif [ -d "malsandbox" ]; then
    cd malsandbox
    pip install -e ".[all]"
    cd ..
else
    echo "[!] malsandbox package not found."
    echo "    Clone the original repo first:"
    echo "    git clone https://github.com/enriqueshr/behaviour-analysis-sandbox.git"
    exit 1
fi

echo "[*] Creating directories..."
mkdir -p lab reports samples/rules intake/{incoming,reports,processed,unreadable}

echo "[+] Setup complete."
echo ""
echo "Activate with:  source .venv/bin/activate"
echo "Test with:      malsandbox-bot --help"
echo "Demo:           python scripts/make-test-sample.py lab/fake_ransom.exe"
echo "Then:           malsandbox-bot lab/fake_ransom.exe --yara samples/rules/example.yar --pdf reports/test.pdf"