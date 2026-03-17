# DeNOVO Solutions — Info/Cybersecurity Specialist 1
## Job Prep: Gap Analysis, Study Guide & Mock Interview

---

## YOUR STRENGTHS (You Already Have These)

- **TS/SCI clearance** (active, granted 2024) — this is a massive differentiator
- **CompTIA Security+** — satisfies the DoD 8570/8140 IAT Level II requirement
- **Azure AZ-900** — foundation for cloud section
- **Splunk Core Certified** — covers security monitoring
- **4+ years IT/cybersecurity in DoD environments** — exceeds the 0-3 year requirement
- **Two B.S. degrees** (Cybersecurity + Digital Forensics) — strong academic profile
- **SIPR/PKI management, SIPRNet ops** — directly relevant to IC/defense contractor work
- **Navy veteran, leadership, incident response** — cultural fit for a SDVOSB/IC company

---

## GAP ANALYSIS — What's Missing

### Critical Gaps (mentioned directly in job posting)
1. **Linux** — not on resume at all; job lists it as desired
2. **Python or Bash scripting** — not on resume; job lists it as desired
3. **Docker / Kubernetes (container security)** — not on resume
4. **AWS or GCP** — only Azure fundamentals; multi-cloud expected
5. **Vulnerability scanning tools** (Nessus, Tenable, OpenVAS) — not named
6. **DevSecOps / CI/CD pipeline security** — not on resume

### Secondary Gaps (highly desired / implied for gov contractors)
7. **NIST RMF / NIST 800-53** — not mentioned (critical for DoD/IC work)
8. **Agile methodology** — not mentioned
9. **Microservices / event-driven architecture security** — not mentioned
10. **Secure SDLC practices** — not mentioned

---

## STUDY GUIDE — Fill the Gaps Fast

---

### 1. Linux Basics for Security

**Goal:** Be able to speak to Linux confidently in an interview

**Key commands to know:**
```bash
ls -la          # list files with permissions
chmod 755 file  # change file permissions
chown user file # change file owner
ps aux          # list running processes
netstat -tulnp  # show open ports (or ss -tulnp)
grep -r "error" /var/log/  # search logs
sudo journalctl -xe         # view system logs
```

**Security-relevant concepts:**
- File permission model (rwx, octal notation)
- User/group management (`useradd`, `usermod`, `/etc/passwd`, `/etc/shadow`)
- Cron jobs and persistence mechanisms (attacker technique too)
- `/var/log/auth.log` and `/var/log/syslog` for incident response
- `iptables` / `ufw` for host-based firewall rules
- SSH hardening (`/etc/ssh/sshd_config` — disable root login, use key auth)

**Quick practice:** Install WSL (Windows Subsystem for Linux) or use TryHackMe's Linux rooms for free.

---

### 2. Python / Bash Scripting for Security

**Goal:** Show you can automate security tasks — you don't need to be a developer

**Bash basics:**
```bash
#!/bin/bash
# Simple log parser
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn
```

**Python basics for security:**
```python
import os, subprocess

# List running processes
result = subprocess.run(['ps', 'aux'], capture_output=True, text=True)
print(result.stdout)

# Simple file hash check (integrity monitoring concept)
import hashlib
def hash_file(path):
    with open(path, 'rb') as f:
        return hashlib.sha256(f.read()).hexdigest()
```

**What to say in interview:**
> "I've used scripting to automate log analysis and routine security checks. I'm comfortable with Bash for system tasks and have been expanding my Python skills for security automation."

**Resources:**
- TryHackMe — "Scripting for Pentesters" room (free)
- Automate the Boring Stuff with Python — pythonlearn.com (free)

---

### 3. Docker & Container Security

**Goal:** Understand containers well enough to discuss security implications

**Core concepts:**
- **Image vs Container:** Image = blueprint, Container = running instance
- **Docker Hub** = public registry (risk: untrusted images with malware)
- **Dockerfile** = instructions to build an image

**Security concerns to know:**
- Running containers as root (bad practice)
- Image vulnerabilities — use `docker scan` or **Trivy** to scan images
- Container escape attacks (breakout from container to host)
- Secrets in environment variables (risk — use secrets managers instead)
- Network isolation between containers (`--network none`)
- Read-only file systems (`--read-only` flag)

**Kubernetes security additions:**
- **RBAC** in K8s (Role-Based Access Control) — limit what pods can do
- **Network Policies** — restrict pod-to-pod communication
- **Pod Security Standards** — prevent privileged containers
- **Secrets management** — K8s secrets vs. Vault

**What to say in interview:**
> "I understand container security fundamentals — image scanning, minimizing attack surface, avoiding privileged containers, and applying RBAC in Kubernetes environments."

---

### 4. AWS / GCP Cloud Security (Expand Beyond Azure)

**You already have AZ-900. Here's the translation:**

| Azure | AWS | GCP |
|-------|-----|-----|
| Azure AD | IAM | Cloud IAM |
| NSG | Security Groups | VPC Firewall Rules |
| Azure Defender | AWS Security Hub / GuardDuty | Security Command Center |
| Azure Monitor | CloudWatch | Cloud Logging |
| Key Vault | AWS Secrets Manager | Secret Manager |

**Key security concepts (apply to all clouds):**
- **IAM least privilege** — only grant permissions needed
- **MFA enforcement** on all accounts
- **S3/Blob public access** — default should be private
- **VPC/Virtual Networks** — network segmentation in cloud
- **CloudTrail / Azure Monitor / GCP Audit Logs** — logging and monitoring
- **Shared Responsibility Model** — cloud secures the infrastructure, YOU secure what's on it

**What to say in interview:**
> "I hold Azure Fundamentals and have been mapping those concepts to AWS and GCP equivalents. I understand IAM, network segmentation, logging, and the shared responsibility model across cloud providers."

**Cert to get:** AWS Cloud Practitioner (~$100, 1-2 weeks prep) — pairs with your AZ-900 nicely.

---

### 5. Vulnerability Scanning & Management

**Key tools to know:**
- **Nessus / Tenable.io** — industry standard; used heavily in DoD
- **OpenVAS** — open source alternative
- **Qualys** — enterprise vulnerability management
- **CVSS scoring** — 0-10 scale; Critical (9-10), High (7-8.9), Medium (4-6.9), Low (0.1-3.9)
- **CVE** — Common Vulnerabilities and Exposures (the identifier system)
- **NVD** — National Vulnerability Database (nvd.nist.gov)

**Vulnerability management lifecycle:**
1. **Discover** — scan assets
2. **Prioritize** — CVSS score + asset criticality
3. **Remediate** — patch, config change, or accept risk
4. **Verify** — rescan to confirm fix
5. **Report** — document for compliance

**What to say:**
> "I'm familiar with vulnerability management concepts and CVSS scoring. I've worked with Splunk for security monitoring and understand the lifecycle from discovery through remediation and reporting."

---

### 6. DevSecOps / CI/CD Pipeline Security

**Goal:** Understand the concept — you don't need to be a DevOps engineer

**What DevSecOps means:**
- "Shift security left" — catch vulnerabilities EARLY in development, not after
- Security is everyone's job, not just the security team's

**CI/CD security touchpoints:**
```
Code → [SAST scan] → Build → [Container scan] → Test → [DAST scan] → Deploy → [Runtime monitoring]
```

- **SAST** (Static Application Security Testing) — scans source code (e.g., SonarQube, Semgrep)
- **DAST** (Dynamic Application Security Testing) — tests running app (e.g., OWASP ZAP, Burp Suite)
- **SCA** (Software Composition Analysis) — scans dependencies for known CVEs (e.g., Snyk, Dependabot)
- **Secrets scanning** — catch API keys/passwords committed to code (e.g., GitLeaks, TruffleHog)

**Tools to name-drop:** GitHub Actions, Jenkins, GitLab CI, Terraform (IaC security)

**What to say:**
> "I understand the DevSecOps model — integrating security gates like SAST, container scanning, and secrets detection into CI/CD pipelines to catch issues before they reach production."

---

### 7. NIST RMF & 800-53 (Critical for DoD/IC Work)

**This is probably your biggest practical gap for this specific role.**

**Risk Management Framework (RMF) — 6 Steps:**
1. **Categorize** — what is the system's impact level? (Low/Moderate/High per FIPS 199)
2. **Select** — choose security controls from NIST 800-53
3. **Implement** — put the controls in place
4. **Assess** — test that controls work (Security Assessment)
5. **Authorize** — AO (Authorizing Official) signs the ATO (Authority to Operate)
6. **Monitor** — continuous monitoring of security posture

**NIST 800-53 Control Families to know:**
- **AC** — Access Control
- **AU** — Audit and Accountability
- **CM** — Configuration Management
- **IA** — Identification and Authentication
- **IR** — Incident Response
- **RA** — Risk Assessment
- **SI** — System and Information Integrity
- **SC** — System and Communications Protection

**Key terms:**
- **ATO** — Authority to Operate (the green light to run a system)
- **POAM** — Plan of Action & Milestones (tracking remediation of findings)
- **STIG** — Security Technical Implementation Guide (DoD config standards)
- **FISMA** — Federal Information Security Modernization Act (the law behind all this)

**What to say:**
> "Through my DoD service and IT work, I've operated within RMF-governed environments. I understand the ATO process, POAM management, and how NIST 800-53 controls map to real security practices. I'm building on this with formal study."

---

### 8. Agile / Scrum Basics

**Enough to not be lost in the interview:**
- **Sprint** — 2-week work cycle
- **Scrum** — daily standups, sprint planning, retrospectives
- **Backlog** — list of work to be done
- **Story Points** — effort estimates
- **Security in Agile** — each sprint includes security tasks; threat modeling early

**What to say:**
> "I've collaborated in fast-paced, mission-driven teams where priorities shift quickly — similar to Agile. I'm familiar with sprint-based workflows and understand how security requirements get incorporated into the development backlog."

---

## MOCK INTERVIEW — 10 Questions with Answers

---

**Q1: Walk me through your background and why you're applying for this role.**

**A:** "I'm a Navy veteran with 4+ years of IT and cybersecurity experience in DoD environments, including active TS/SCI clearance. I've managed PKI/SIPR infrastructure, supported classified network operations, and hold certifications including Security+ and Splunk. DeNOVO's focus on the Intelligence Community aligns directly with my background, and as a SDVOSB, I'm particularly motivated to contribute to a mission-driven team that values service. This role is a natural next step from operational IT support into a dedicated cybersecurity function."

---

**Q2: What does the NIST Risk Management Framework mean to you, and have you worked within it?**

**A:** "The RMF is the six-step process DoD and federal agencies use to manage cybersecurity risk — categorize, select, implement, assess, authorize, and monitor. Working in DoD IT environments, I've operated systems that have gone through the ATO process and have helped ensure compliance with applicable STIGs and security controls. I understand how POAM items track remediation efforts and the continuous monitoring piece is something I've supported through log review and security audits."

---

**Q3: You don't have direct container security experience listed. How would you approach learning it on the job?**

**A:** "You're right that containers are an area I'm actively developing. I understand the core security concerns — image vulnerabilities, privileged containers, container escape risks, and RBAC in Kubernetes. I'm hands-on by nature and would prioritize getting up to speed by running Docker in a home lab, using tools like Trivy for image scanning, and leveraging resources like the CIS Docker Benchmark. I've picked up new technologies quickly throughout my Navy career — that pattern of rapid technical learning is one of my strengths."

---

**Q4: Describe your experience with vulnerability management.**

**A:** "In my current role managing SIPR infrastructure, I conduct IT security reviews and system audits to ensure compliance. I'm familiar with CVSS scoring and how to prioritize vulnerabilities based on both severity and asset criticality. I've used Splunk to monitor for indicators of compromise and anomalous activity. I'm familiar with tools like Nessus and Tenable in concept and am building hands-on experience with them. I understand the full lifecycle from scanning through remediation verification and reporting."

---

**Q5: What does 'shift left' mean in a DevSecOps context?**

**A:** "Shift left means integrating security earlier in the software development lifecycle rather than treating it as an end-of-pipeline check. Instead of security reviews only before deployment, you embed SAST scanning in the code commit stage, dependency scanning in the build stage, and container scanning before images are promoted. This catches vulnerabilities when they're cheap to fix — in development — rather than after the fact in production. It also means developers take shared ownership of security rather than tossing it over the wall to a security team."

---

**Q6: How do you approach securing cloud infrastructure?**

**A:** "I start with IAM — enforcing least privilege so no account or service has more access than it needs. I make sure MFA is enforced on all privileged accounts. For network security, I apply the principle of segmentation — VPCs, security groups, and network ACLs to limit blast radius if something is compromised. I ensure logging is enabled — CloudTrail in AWS, Azure Monitor, or equivalent — so there's an audit trail. I hold Azure Fundamentals and have been studying AWS security services like GuardDuty and Security Hub. The underlying principles are consistent across cloud providers."

---

**Q7: Tell me about a time you had to respond to a security incident or policy violation.**

**A:** "At TQI Solutions, I've handled situations where SIPR tokens needed immediate revocation due to personnel changes or suspected compromise. The process involves quickly disabling access, documenting the incident, notifying the appropriate parties, and ensuring no unauthorized access occurred during the window. In the Navy, I responded to incidents during security watch — assessing situations, following escalation procedures, and writing incident reports. I understand that speed and accuracy both matter in incident response, and documentation is critical for after-action review."

---

**Q8: What scripting experience do you have, and how would you use it in a security role?**

**A:** "I've used scripting primarily for automation of repetitive tasks and data analysis — including work with Excel and Power BI in my intel role. I'm building my Python and Bash capabilities specifically for security applications: log parsing, automating vulnerability report generation, and eventually integrating with APIs for security tool orchestration. I understand the value — a 10-line script that automates a daily check saves hours a week and reduces human error. I'm comfortable acknowledging I'm still developing here while demonstrating I understand the use cases."

---

**Q9: Why are you a good fit specifically for a company that supports the Intelligence Community?**

**A:** "My entire professional background has been in or supporting the IC and DoD. I hold an active TS/SCI granted in 2024, I've worked on SIPRNet, I've handled classified data, and I've supported terrorism watch listing missions at CNRFC. I understand the culture — mission first, discretion always, zero tolerance for security lapses. DeNOVO being a Service-Disabled Veteran-Owned Small Business matters to me personally as a veteran. I want to work somewhere that understands the operational context behind the security work, and this company does."

---

**Q10: Where do you see your gaps, and what are you doing to close them?**

**A:** "I'm honest about my gaps. My hands-on cloud experience is Azure-focused, so I'm working toward AWS Cloud Practitioner to round out multi-cloud coverage. Containers and DevSecOps are areas I'm actively developing through home lab work and targeted study. On the framework side, I have practical RMF experience from DoD environments but am formalizing that knowledge. I'm also exploring CEH or CySA+ as a next cert. The foundation is strong — clearance, DoD background, Security+, Splunk — and I'm building the modern cloud-native skills on top of that."

---

## QUICK CERT ROADMAP (Priority Order)

1. **AWS Cloud Practitioner** — ~$100, 1-2 weeks, closes the multi-cloud gap
2. **CompTIA CySA+** — next DoD 8570 cert (IAT Level III territory), strong for this role
3. **AWS Security Specialty** or **CCSP** — longer term, major differentiator
4. **Kubernetes/CKS** — if you want to go deep on container security

---

## KEY TERMS CHEAT SHEET

| Term | Definition |
|------|-----------|
| ATO | Authority to Operate — gov approval to run a system |
| POAM | Plan of Action & Milestones — remediation tracker |
| STIG | Security Technical Implementation Guide — DoD config standards |
| RMF | Risk Management Framework — NIST's security lifecycle |
| CVSS | Common Vulnerability Scoring System — 0-10 risk score |
| CVE | Common Vulnerabilities and Exposures — vuln identifier |
| SAST | Static Application Security Testing — scans source code |
| DAST | Dynamic Application Security Testing — scans running app |
| IAM | Identity and Access Management — controls who can do what |
| RBAC | Role-Based Access Control — permissions by role, not individual |
| DevSecOps | Security integrated into DevOps pipeline |
| CI/CD | Continuous Integration / Continuous Deployment — automated build/deploy |
| Shift Left | Move security earlier in the dev lifecycle |
| Container | Isolated runtime environment (Docker) |
| Orchestration | Managing containers at scale (Kubernetes) |

---

*Generated for DeNOVO Solutions — Information/Cybersecurity Specialist 1 application*
*Based on resume: Justin Youngs | Jyoungs42433@gmail.com*
