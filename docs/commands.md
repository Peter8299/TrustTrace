[← README](../README.md) · [Capabilities](capabilities.md) · [Commands](commands.md) · [HTTP API](api.md) · [Wireshark](wireshark.md) · [Architecture](architecture.md) · [Walkthrough](walkthrough.md)

---

# Command reference

Every command supports `--help` and `--cases-dir` (env `TRUSTTRACE_CASES_DIR`, default `cases`).

**Cases**
```bash
trusttrace case create --name "Incident" [--description "..."] [--investigator "..."]
trusttrace case list
trusttrace case status --case INC-0001 open|investigating|closed
trusttrace case audit  --case INC-0001 [--verify]
trusttrace case export --case INC-0001 [--output INC-0001.zip]
trusttrace case import ./INC-0001.zip [--cases-dir other_cases]
trusttrace case delete --case INC-0001              # irreversible; see below
```

`case delete` removes the evidence copies, the event store, carved artifacts, findings, reports **and the chain of custody** — the audit log lives inside the case directory. There is no soft delete and no trash: a forensics tool that pretends to delete evidence while keeping a copy is worse than one that deletes it, because the copy is then unaccounted for. Both the CLI and the web UI make you **type the case ID** rather than click through a yes/no, and both report what was removed.

**Evidence**
```bash
trusttrace evidence add ./file --case INC-0001     # .pcap/.pcapng/.json/.csv/.evtx
trusttrace evidence list --case INC-0001
trusttrace parse --case INC-0001 --evidence EV-0001 [--engine auto|tshark|scapy] [--display-filter '...']
```

**Analysis**
```bash
trusttrace analyze --case INC-0001                 # parse + correlate + detect
trusttrace analyze --case INC-0001 --engine tshark # pin the dissection engine
trusttrace timeline build --case INC-0001
trusttrace timeline show  --case INC-0001 [--user ...] [--ip ...] [--type ...] [--evidence EV-0001]
trusttrace detections list --case INC-0001 [--severity high]
```

**Demo** — a fabricated incident, end to end, in one command
```bash
trusttrace demo [--cases-dir cases] [--open] [--port 8000]
```

Builds the synthetic capture (`trusttrace/demo.py`), creates a new case for it, analyzes it and prints the story. `--open` then starts the web UI and opens the case's story. Needs the `pcap` extra.

**The story** — what happened, rather than how many objects there are
```bash
trusttrace story --case INC-0001
```

Assembles the case into an account: beats (one per rule, grouped), grouped into the stages of an intrusion, under a one-sentence assessment. Same thing at `GET /api/cases/<id>/narrative`, in the web UI's **What happened** tab, and as the `## What Happened` section of an exported report.

It is **deterministic** — no model, no network, no score that can't be explained. A narrative that goes into an incident report has to be reproducible by whoever reads it, and *"the language model said so"* is not a chain of custody. The AI assistant may interpret the narrative; it is not permitted to write it.

Every beat names the `event_id`s it rests on, so each sentence walks back to a packet — in the UI those ids are clickable and resolve to the Wireshark display filter that isolates them.

A case with no detections still produces a story, and it says so plainly:

> No bundled detection rule matched this evidence. That is not the same as 'nothing happened' — it means nothing matched the rules that exist.


**Wireshark** *(only available when Wireshark is installed — see [Wireshark integration](wireshark.md))*
```bash
trusttrace wireshark status                        # what was found, which engines are live
trusttrace wireshark check-filter 'tls.handshake.extensions_server_name contains "c2"'
trusttrace wireshark open  --case INC-0001 --event EVT-EV-0001-000042   # or --evidence EV-0001, + --print
trusttrace wireshark slice --case INC-0001 --evidence EV-0001 --display-filter 'dns'
```

**Investigation**
```bash
trusttrace investigate --case INC-0001 --ip 192.168.1.10
#   or --user / --hash / --host / --domain / --process / --file / --device
trusttrace investigate --case INC-0001 --ip 1.2.3.4 --vt-api YOUR_KEY
trusttrace investigate --case INC-0001 --ip 1.2.3.4 --ai --ai-provider ollama
trusttrace investigate --case INC-0001 --ip 1.2.3.4 --ai --ai-provider gemini --model gemini-3.6-flash
```

**Threat intel** — import indicators and match them against the case
```bash
trusttrace ioc import ./campaign.txt --case INC-0001 [--source "Vendor X, Sep 2026"]
trusttrace ioc list   --case INC-0001 [--type domain]   # matched indicators are marked
trusttrace ioc clear  --case INC-0001 [--source "Vendor X, Sep 2026"]
```

Reads plain text, CSV, STIX 2.1 and MISP JSON. Importing re-runs detections at once, so matches appear immediately and lead `trusttrace story`. Every refused line is printed with its reason. See [Indicator matching](capabilities.md#indicator-matching) for what is accepted and why.

**Findings**
```bash
trusttrace finding create --case INC-0001 --title "..." --severity High --event EVT-...
trusttrace finding list   --case INC-0001
trusttrace finding update --case INC-0001 --finding F-0001 --status Confirmed --note "..."
```

**MITRE ATT&CK**
```bash
trusttrace attack scan   --case INC-0001
trusttrace attack list   --case INC-0001
trusttrace attack update --case INC-0001 --technique T1059.001 --status confirmed
```

**Reports · Capture · Web**
```bash
trusttrace report generate --case INC-0001 --format markdown|json|html [--output PATH]
trusttrace capture --list-interfaces
trusttrace capture --case INC-0001 --interface "\Device\NPF_{...}" --filter "tcp port 443" --rotate-seconds 30
trusttrace capture --case INC-0001 --engine dumpcap|scapy   # default: auto
trusttrace web --cases-dir cases [--host 127.0.0.1] [--port 8000] [--allow-host NAME]
trusttrace scan ./capture.pcap [--vt-api KEY] [--save-files] [--no-dashboard]   # legacy standalone
```

---
