# CCNA 200-301 Complete Study Guide

> A zero-to-exam reference covering every major topic on the Cisco CCNA 200-301 exam.
> Includes CLI examples, ASCII network diagrams, and exam tips throughout.

---

## What's Inside

| Chapter | Topic | Exam Weight |
|---------|-------|-------------|
| [01 - Network Fundamentals](chapters/01-network-fundamentals.md) | OSI, TCP/IP, IPv4, Subnetting, IPv6, Switching | 20% |
| [02 - Network Access](chapters/02-network-access.md) | VLANs, Trunking, STP, EtherChannel, Wireless | 20% |
| [03 - IP Connectivity](chapters/03-ip-connectivity.md) | Routing, Static Routes, OSPFv2, FHRP | 25% |
| [04 - IP Services](chapters/04-ip-services.md) | DHCP, DNS, NAT, NTP, SNMP, SSH, QoS | 10% |
| [05 - Security Fundamentals](chapters/05-security.md) | ACLs, L2 Security, VPNs, AAA, Wireless Security | 15% |
| [06 - Automation](chapters/06-automation.md) | SDN, DNA Center, REST APIs, Ansible, JSON | 10% |

---

## How to Use This Guide

1. Read each chapter in order — topics build on each other
2. Practice every CLI example in a lab (use [Cisco Packet Tracer](https://www.netacad.com/courses/packet-tracer) — it's free)
3. After each chapter, quiz yourself on the key points
4. For subnetting, practice until you can do it in your head
5. Use the exam tips (`> **Exam Tip:**`) scattered throughout

---

## Generate a PDF

### Option 1 — Pandoc (Best Quality)

Install [pandoc](https://pandoc.org/installing.html) and a LaTeX engine ([MiKTeX](https://miktex.org/) on Windows or [MacTeX](https://www.tug.org/mactex/) on macOS).

```bash
# Install pandoc, then run:
pandoc README.md chapters/*.md \
  -o CCNA-Complete-Guide.pdf \
  --toc \
  --toc-depth=3 \
  -V geometry:margin=1in \
  -V fontsize=11pt \
  --highlight-style=tango
```

### Option 2 — VS Code Extension

1. Install the **Markdown PDF** extension in VS Code
2. Open `CCNA-Complete-Guide.md`
3. Right-click → **Export (pdf)**

### Option 3 — Browser Print

1. Open `CCNA-Complete-Guide.md` on GitHub
2. Press `Ctrl+P` → **Save as PDF**

---

## About the Exam

- **Exam Code:** 200-301 CCNA
- **Duration:** 120 minutes
- **Questions:** 95–100 (multiple choice, drag & drop, simulation)
- **Passing Score:** ~825/1000
- **Cost:** ~$330 USD
- **Validity:** 3 years

---

## Lab Environment

All CLI examples use **Cisco IOS**. Practice options:

| Tool | Cost | Notes |
|------|------|-------|
| Cisco Packet Tracer | Free (NetAcad account) | Best for beginners |
| GNS3 | Free | Real IOS images needed |
| EVE-NG | Free/Paid | Professional-grade |
| Cisco DevNet Sandbox | Free | Cloud-based labs |

---

*This guide covers the CCNA 200-301 exam objectives. Always check [cisco.com](https://www.cisco.com/c/en/us/training-events/training-certifications/exams/current-list/ccna-200-301.html) for the latest exam blueprint.*
