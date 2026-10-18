/*
 * Example YARA rules for the Nobel Wazuh + Windows 10 lab.
 * Extend freely. The framework reads meta.description / severity / weight / attack.
 * Requires: pip install yara-python
 */

rule Eicar_Test_File
{
    meta:
        description = "EICAR antivirus test file (harmless)"
        severity = "info"
        weight = "0"
    strings:
        $e = "EICAR-STANDARD-ANTIVIRUS-TEST-FILE"
    condition:
        $e
}

rule Suspicious_Ransom_Note
{
    meta:
        description = "Looks like a ransom note / payment demand"
        severity = "high"
        weight = "30"
        attack = "T1486"
    strings:
        $a = "your files have been encrypted" nocase
        $b = "bitcoin" nocase
        $c = "decrypt" nocase
        $d = "pay the ransom" nocase
        $e = "files are encrypted" nocase
    condition:
        2 of them
}

rule Shadow_Copy_Deletion
{
    meta:
        description = "Deletes volume shadow copies (anti-recovery)"
        severity = "high"
        weight = "25"
        attack = "T1490"
    strings:
        $v = "vssadmin delete shadows" nocase
        $w = "wbadmin delete catalog" nocase
        $x = "bcdedit /set {default} recoveryenabled no" nocase
    condition:
        any of them
}

rule Suspicious_RMM_or_Remote_Access
{
    meta:
        description = "Possible remote access / RMM tooling strings"
        severity = "medium"
        weight = "15"
        attack = "T1219"
    strings:
        $a = "ScreenConnect" nocase
        $b = "AnyDesk" nocase
        $c = "Atera" nocase
        $d = "TeamViewer" nocase
        $e = "unattended" nocase
    condition:
        2 of them
}