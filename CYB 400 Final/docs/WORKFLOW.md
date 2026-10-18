
---

### 4. `docs/WORKFLOW.md`

```markdown
# Complete Analysis Workflow – Nobel Lab (Wazuh + Windows 10 + malsandbox)

## Goal
Produce a full static + behavioural report using:
- Static analysis & YARA inside malsandbox
- Runtime behaviour from Sysmon collected via Wazuh agent on Windows 10

## Phase 0 – One-time Lab Setup
1. Follow `docs/SETUP-WIN10-WAZUH.md` on the Windows 10 VM.
2. On the analysis host (Kali recommended):
   ```bash
   git clone <your-nobel-repo>
   cd Nobel-malsandbox-wazuh-win10
   git clone https://github.com/enriqueshr/behaviour-analysis-sandbox.git
   bash scripts/setup-kali.sh