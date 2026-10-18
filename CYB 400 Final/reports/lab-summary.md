# Nobel Lab – Analysis Summary Report
**Date:** 2026-10-18  
**Environment:** Windows 10 (WIN10-LAB) + Wazuh agent + Sysmon → malsandbox on analysis host  
**Operator:** Nobel

## Samples Analysed

| Sample              | SHA-256 (short)      | Verdict     | Risk | Notes                                      |
|---------------------|----------------------|-------------|------|--------------------------------------------|
| fake_ransom.exe     | 0515a0bdd7...87f24  | MALICIOUS   | 100  | Inert training stub – full static + behaviour |
| notepad_copy.exe    | 468ffe129c...577e   | BENIGN      | 0    | Known-good control (copy of notepad.exe)  |

## Key Observations – fake_ransom.exe

**Static**
- High entropy (7.88) – appears packed
- Suspicious APIs: VirtualAllocEx, WriteProcessMemory, CreateRemoteThread, CryptEncrypt
- Embedded ransom-note phrases + bitcoin / .onion / vssadmin strings
- YARA hits: Suspicious_Ransom_Note, Shadow_Copy_Deletion

**Behaviour (Sysmon on Windows 10)**
- Spawned vssadmin to delete shadow copies
- Created multiple `*.locked` files in user profile
- Wrote persistence Run key
- Made outbound connection to 185.234.72.11:443
- Launched encoded PowerShell (download cradle pattern)

**ATT&CK mapping**
T1055, T1486, T1547.001, T1490, T1059, T1071, T1105, T1622

## Lab Notes
- Windows 10 analysis VM was restored from `clean-baseline` snapshot after each run.
- Real-time protection disabled inside the lab VM only.
- All telemetry collected via Sysmon and forwarded by Wazuh agent.
- malsandbox consumed the sample + Sysmon CSV export and produced the reports in `/reports`.

## Recommendations
1. Treat any real sample showing the same combination of static + behavioural indicators as high-confidence ransomware.
2. Continue using the inert `make-test-sample.py` stub for pipeline validation.
3. Keep real malware out of the git repository; store only reports and IOCs.

---
*Generated automatically by the Nobel lab workflow.*