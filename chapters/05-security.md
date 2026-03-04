# Chapter 5: Security Fundamentals

> **Exam Weight: 15%**

---

## Table of Contents
1. [Security Concepts](#1-security-concepts)
2. [Threats and Attack Types](#2-threats-and-attack-types)
3. [Device Hardening](#3-device-hardening)
4. [Access Control Lists (ACLs)](#4-access-control-lists-acls)
5. [Layer 2 Security](#5-layer-2-security)
6. [VPNs](#6-vpns)
7. [AAA (Authentication, Authorization, Accounting)](#7-aaa-authentication-authorization-accounting)
8. [Wireless Security Protocols](#8-wireless-security-protocols)

---

## 1. Security Concepts

### CIA Triad

The three core principles of information security:

```
┌─────────────────────────────────────────────────────────────┐
│                        CIA TRIAD                            │
│                                                             │
│   CONFIDENTIALITY      INTEGRITY       AVAILABILITY         │
│   ─────────────────   ─────────────   ───────────────────  │
│   Only authorized     Data is          Systems are up       │
│   users can access    accurate &       and accessible       │
│   the information     unmodified       when needed          │
│                                                             │
│   Examples:           Examples:        Examples:            │
│   Encryption          Hashing          Redundancy           │
│   Access control      Digital sigs     Backups              │
│   Authentication      Checksums        High availability    │
└─────────────────────────────────────────────────────────────┘
```

### Security Program Elements

| Element | Description |
|---------|-------------|
| **Vulnerability** | A weakness that could be exploited |
| **Threat** | A potential cause of an incident |
| **Exploit** | A method that takes advantage of a vulnerability |
| **Risk** | Likelihood × Impact of a threat |
| **Countermeasure** | Control that reduces risk |
| **Zero-day** | Exploit for unknown/unpatched vulnerability |

### Defense in Depth

Use multiple layers of security controls:
```
Internet → Firewall → IPS → Router ACL → Switch Port Security → Host firewall → Application
```

---

## 2. Threats and Attack Types

### Common Network Attacks

**DoS (Denial of Service)** — Overwhelm a system to make it unavailable
- **SYN Flood** — Send many SYN packets without completing handshake (half-open connections fill up state table)
- **Amplification** — Use third-party servers to amplify traffic toward victim (DNS/NTP amplification)
- **DDoS** — Distributed DoS from many sources (botnet)

**Man-in-the-Middle (MitM)** — Intercept communications between two parties
- ARP Spoofing/Poisoning — send fake ARP replies to redirect traffic
- DNS Spoofing — corrupt DNS cache to redirect to malicious IP

**Social Engineering** — Manipulate humans
- **Phishing** — Fake emails/sites to steal credentials
- **Spear phishing** — Targeted phishing at specific individuals/organizations
- **Vishing** — Voice phishing (phone call)
- **Whaling** — Phishing targeting executives

**Reconnaissance** — Gather info before attacking
- **Ping sweeps** — find live hosts
- **Port scanning** — find open ports/services
- **OS fingerprinting** — identify OS/software versions

**Password Attacks**
- **Brute force** — try all combinations
- **Dictionary attack** — try common words/passwords
- **Rainbow table** — precomputed hash lookup
- **Password spraying** — try common passwords across many accounts

**Layer 2 Attacks**
- **MAC flooding** — fill CAM table to make switch flood like a hub
- **VLAN hopping** — double-tagging to reach other VLANs
- **DHCP starvation** — exhaust DHCP pool
- **DHCP spoofing** — fake DHCP server
- **ARP poisoning** — corrupt ARP cache

---

## 3. Device Hardening

### Password Security

```
! Enable Secret (hashed, recommended)
Router(config)# enable secret StrongPassword123!
! Do NOT use: enable password (cleartext)

! Create privileged user accounts
Router(config)# username admin privilege 15 secret Admin@Pass123
Router(config)# username operator privilege 5 secret Op@Pass456

! Encrypt all passwords in config
Router(config)# service password-encryption     ! weak encryption (Type 7), better than nothing

! Set minimum password length
Router(config)# security passwords min-length 10

! Set login failure delay
Router(config)# login block-for 120 attempts 3 within 60
! Block for 120 seconds if 3 failures within 60 seconds

! Show that passwords are encrypted in config
Router# show running-config | include password
enable secret 5 $1$Z7nT$kY7YY...        ← hashed (MD5)
username admin secret 5 $1$mQ...        ← hashed
```

### Console and VTY Lines

```
! Secure console line
Router(config)# line console 0
Router(config-line)# login local              ! require username + password
Router(config-line)# exec-timeout 5 0         ! 5 minute timeout (0 = never)
Router(config-line)# logging synchronous      ! prevent log messages interrupting typing
Router(config-line)# exit

! Secure VTY lines (remote access)
Router(config)# line vty 0 15
Router(config-line)# login local
Router(config-line)# transport input ssh      ! SSH only — disable Telnet
Router(config-line)# exec-timeout 10 0
Router(config-line)# access-class 10 in      ! restrict which IPs can connect
Router(config-line)# exit

! ACL to permit only management subnet to VTY
Router(config)# ip access-list standard 10
Router(config-std-nacl)# permit 10.1.1.0 0.0.0.255
Router(config-std-nacl)# deny any log
Router(config-std-nacl)# exit
```

### Disable Unused Services

```
! Disable unnecessary services (security hardening)
Router(config)# no service finger                ! disable finger service
Router(config)# no service pad                   ! disable packet assembler
Router(config)# no service tcp-small-servers     ! disable echo, discard, etc.
Router(config)# no service udp-small-servers
Router(config)# no ip http server                ! disable HTTP (use HTTPS only)
Router(config)# ip http secure-server            ! enable HTTPS management
Router(config)# no ip finger
Router(config)# no ip bootp server              ! disable BOOTP
Router(config)# no cdp run                      ! disable CDP (on edge devices)
Router(config)# no ip proxy-arp                 ! disable proxy ARP

! Disable unused interfaces
Router(config)# interface GigabitEthernet0/5
Router(config-if)# shutdown
Router(config-if)# description UNUSED

! Add banners (legal notice)
Router(config)# banner motd ^
*** AUTHORIZED ACCESS ONLY ***
Unauthorized access is prohibited.
All connections are monitored.
^

Router(config)# banner login ^
Enter your credentials to continue.
^
```

### Privilege Levels

Cisco IOS has 16 privilege levels (0-15):
- Level 0: Limited (logout, enable, disable)
- Level 1: User EXEC (default)
- Level 15: Privileged EXEC (full access)

```
! Assign commands to specific privilege levels
Router(config)# privilege exec level 5 show ip route   ! let level 5 users see routes
Router(config)# privilege exec level 5 ping            ! let level 5 users ping

! Set enable password for each level
Router(config)# enable secret level 5 LimitedPass123
```

---

## 4. Access Control Lists (ACLs)

ACLs **filter network traffic** based on matching criteria. They are applied on router interfaces.

### ACL Processing Rules

```
ACL PROCESSING:
────────────────────────────────────────────────────────────────
Packet arrives → Check ACE 1 → Match? → Permit or Deny action
                      ↓ No match
                Check ACE 2 → Match? → Permit or Deny action
                      ↓ No match
                Check ACE 3 → Match? → Permit or Deny action
                      ↓ No match
              IMPLICIT DENY ALL ← Every ACL ends with this!

IMPORTANT RULES:
1. First match wins — order matters!
2. Every ACL has an implicit "deny all" at the end
3. At minimum, one "permit" must be present or all traffic is blocked
4. ACLs are applied per interface per direction (inbound or outbound)
```

### ACL Placement

```
! STANDARD ACL: Place CLOSE to destination (matches source IP only)
! EXTENDED ACL: Place CLOSE to source (matches src/dst IP + ports)

NETWORK:
[PC: 10.1.1.5]──[R1]────[R2]──[SERVER: 10.2.2.10]

"Deny PC from reaching SERVER":
  Standard ACL (match src 10.1.1.5):
    → Place on R2 closest to server
  Extended ACL (match src 10.1.1.5 dst 10.2.2.10):
    → Place on R1 closest to source PC
```

### Standard ACLs

Match **source IP address only**. Use for simple source-based filtering.

Numbered standard ACLs: 1-99 and 1300-1999

```
! Standard numbered ACL
Router(config)# access-list 10 permit 192.168.1.0 0.0.0.255    ! permit subnet
Router(config)# access-list 10 permit 10.1.1.5               ! permit single host
Router(config)# access-list 10 deny any                       ! explicit deny (same as implicit)

! Apply to interface
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ip access-group 10 in                      ! inbound
Router(config-if)# exit

! Standard NAMED ACL (preferred — more readable)
Router(config)# ip access-list standard MGMT-ACCESS
Router(config-std-nacl)# remark Allow management subnet
Router(config-std-nacl)# permit 10.1.1.0 0.0.0.255
Router(config-std-nacl)# remark Deny all others
Router(config-std-nacl)# deny any log
Router(config-std-nacl)# exit

Router(config)# line vty 0 15
Router(config-line)# access-class MGMT-ACCESS in
```

### Wildcard Masks

Wildcard masks are the **inverse** of subnet masks. Used in ACL matching.

```
Subnet mask:   255.255.255.0    = network portion (1s)
Wildcard mask: 0.0.0.255        = match these bits (0 = must match, 1 = don't care)

EXAMPLES:
─────────────────────────────────────────────────────────────────
Match exact host:     0.0.0.0         (10.1.1.5 0.0.0.0)
Match /24 subnet:     0.0.0.255       (10.1.1.0 0.0.0.255)
Match /16 subnet:     0.0.255.255     (10.1.0.0 0.0.255.255)
Match /8 network:     0.255.255.255   (10.0.0.0 0.255.255.255)
Match any host:       255.255.255.255 (= "any" keyword)
Match this host only: 0.0.0.0        (= "host" keyword)

SHORTCUTS:
  host 10.1.1.5  = 10.1.1.5 0.0.0.0
  any            = 0.0.0.0 255.255.255.255
```

### Extended ACLs

Match **source IP, destination IP, protocol, and ports**. More granular than standard ACLs.

Numbered extended ACLs: 100-199 and 2000-2699

```
! Extended numbered ACL syntax
! access-list number {permit|deny} protocol src wildcard dst wildcard [port conditions]

! Deny Telnet from 10.1.1.0/24 to 10.2.2.0/24
Router(config)# access-list 100 deny tcp 10.1.1.0 0.0.0.255 10.2.2.0 0.0.0.255 eq 23

! Permit all HTTP from any source to server 10.2.2.10
Router(config)# access-list 100 permit tcp any host 10.2.2.10 eq 80

! Permit HTTPS to server
Router(config)# access-list 100 permit tcp any host 10.2.2.10 eq 443

! Permit ICMP (ping)
Router(config)# access-list 100 permit icmp any any

! Deny all else (implicit anyway, but explicit for log)
Router(config)# access-list 100 deny ip any any log

! Apply outbound on interface toward 10.2.2.0/24
Router(config)# interface GigabitEthernet0/1
Router(config-if)# ip access-group 100 out

! Extended NAMED ACL (preferred)
Router(config)# ip access-list extended FILTER-WEB
Router(config-ext-nacl)# remark Permit HTTP/HTTPS to web server
Router(config-ext-nacl)# permit tcp any host 10.2.2.10 eq 80
Router(config-ext-nacl)# permit tcp any host 10.2.2.10 eq 443
Router(config-ext-nacl)# remark Deny Telnet
Router(config-ext-nacl)# deny tcp any any eq 23 log
Router(config-ext-nacl)# remark Permit all other IP
Router(config-ext-nacl)# permit ip any any
Router(config-ext-nacl)# exit
```

### Port Operators in Extended ACLs

| Operator | Meaning | Example |
|----------|---------|---------|
| `eq` | Equal to | `eq 80` — port 80 only |
| `ne` | Not equal to | `ne 80` — not port 80 |
| `lt` | Less than | `lt 1024` — ports 0-1023 |
| `gt` | Greater than | `gt 1024` — ports 1025+ |
| `range` | Range | `range 20 21` — ports 20 and 21 |

### ACL Verification and Editing

```
! Show ACLs
Router# show ip access-lists
Router# show ip access-lists 100              ! specific ACL
Router# show running-config | section access-list

Extended IP access list FILTER-WEB
    10 permit tcp any host 10.2.2.10 eq www    ← sequence number: 10
    20 permit tcp any host 10.2.2.10 eq 443    ← sequence number: 20
    30 deny tcp any any eq 23 log
    40 permit ip any any

! Show ACL applied to interfaces
Router# show ip interface GigabitEthernet0/1
  Outgoing access list is FILTER-WEB
  Inbound  access list is not set

! Editing named ACLs (add/delete specific entries by sequence number)
Router(config)# ip access-list extended FILTER-WEB
Router(config-ext-nacl)# no 30              ! delete sequence 30
Router(config-ext-nacl)# 25 deny tcp any any eq 23 log   ! insert before 30

! Clearing ACL statistics (match counters)
Router# clear ip access-list counters FILTER-WEB
```

---

## 5. Layer 2 Security

### Port Security

**Port security** limits which MAC addresses can use a switch port and how many. Prevents MAC flooding and unauthorized device connections.

```
! Enable port security on access port
Switch(config)# interface GigabitEthernet0/1
Switch(config-if)# switchport mode access
Switch(config-if)# switchport port-security                    ! enable
Switch(config-if)# switchport port-security maximum 2          ! max 2 MACs (default 1)

! Static secure MAC
Switch(config-if)# switchport port-security mac-address aabb.cc00.0100

! Sticky — learns and makes dynamic MACs permanent in config
Switch(config-if)# switchport port-security mac-address sticky

! Violation modes:
! shutdown (default) — port goes err-disabled, sends SNMP trap + syslog
! restrict          — drops frames, increments counter, sends syslog
! protect           — silently drops frames, NO syslog/SNMP

Switch(config-if)# switchport port-security violation restrict

! Verify port security
Switch# show port-security interface GigabitEthernet0/1

Port Security              : Enabled
Port Status                : Secure-up
Violation Mode             : Shutdown
Aging Time                 : 0 mins
Aging Type                 : Absolute
SecureStatic Address Aging : Disabled
Maximum MAC Addresses      : 2
Total MAC Addresses        : 1
Configured MAC Addresses   : 0
Sticky MAC Addresses       : 1
Last Source Address:Vlan   : aabb.cc00.0100:1
Security Violation Count   : 0

Switch# show port-security                  ! summary of all ports

! Recovery from err-disabled
Switch(config)# interface GigabitEthernet0/1
Switch(config-if)# shutdown
Switch(config-if)# no shutdown

! Auto-recovery from err-disabled
Switch(config)# errdisable recovery cause psecure-violation
Switch(config)# errdisable recovery interval 300    ! 5 minutes
```

### DHCP Snooping

**DHCP Snooping** prevents rogue DHCP servers on untrusted ports. Creates a DHCP binding table used by DAI.

```
! Enable DHCP snooping globally
Switch(config)# ip dhcp snooping
Switch(config)# ip dhcp snooping vlan 10          ! enable on VLAN 10
Switch(config)# no ip dhcp snooping information option  ! option 82 (remove if issues arise)

! Trusted port = toward legitimate DHCP server or uplink
Switch(config)# interface GigabitEthernet0/24     ! uplink to router (DHCP server)
Switch(config-if)# ip dhcp snooping trust
Switch(config-if)# exit

! Untrusted = client-facing ports (default — no config needed)
! Rate limit DHCP on untrusted ports (prevent DHCP starvation)
Switch(config)# interface GigabitEthernet0/1
Switch(config-if)# ip dhcp snooping limit rate 10  ! max 10 DHCP packets/sec

! Verify
Switch# show ip dhcp snooping
Switch# show ip dhcp snooping binding

MacAddress          IpAddress    Lease(sec)  Type           VLAN  Interface
─────────────────── ──────────── ─────────── ──────────── ──── ──────────────
aa:bb:cc:00:01:00   10.1.1.11    86400       dhcp-snooping  10   Gi0/1
```

### Dynamic ARP Inspection (DAI)

**DAI** validates ARP packets against the DHCP snooping binding table, preventing ARP spoofing/poisoning.

```
! Enable DAI (requires DHCP snooping to be configured first)
Switch(config)# ip arp inspection vlan 10

! Trusted port = toward router/other trusted switches
Switch(config)# interface GigabitEthernet0/24
Switch(config-if)# ip arp inspection trust
Switch(config-if)# exit

! Client ports are untrusted by default
! Rate limit ARP on untrusted ports (prevent ARP flooding)
Switch(config)# interface GigabitEthernet0/1
Switch(config-if)# ip arp inspection limit rate 100   ! max 100 ARPs/sec

! Verify DAI
Switch# show ip arp inspection
Switch# show ip arp inspection vlan 10
Switch# show ip arp inspection statistics
```

### 802.1X (Port-Based Network Access Control)

**802.1X** authenticates devices before allowing network access. Uses RADIUS.

```
COMPONENTS:
  Supplicant  = The client device requesting access (PC, phone)
  Authenticator = The switch/AP that enforces access
  Authentication Server = RADIUS server (checks credentials)

PROCESS:
[PC]───EAPOL───[SWITCH]──RADIUS──[AAA Server]
  1. PC connects → switch port in unauthorized state (blocks data)
  2. Switch sends EAP request
  3. PC provides credentials
  4. Switch forwards to RADIUS
  5. RADIUS accepts/rejects
  6. If accepted: port moves to authorized state
  7. PC gets network access
```

```
! Configure 802.1X on switch
Switch(config)# aaa new-model
Switch(config)# aaa authentication dot1x default group radius
Switch(config)# dot1x system-auth-control          ! enable 802.1X globally

Switch(config)# radius-server host 10.1.1.200 key RADIUS-Secret

Switch(config)# interface GigabitEthernet0/1
Switch(config-if)# authentication port-control auto   ! enable 802.1X
Switch(config-if)# dot1x pae authenticator

! Verify
Switch# show dot1x all
Switch# show authentication sessions
```

### Spanning Tree Security Features (Review)

```
! PortFast — skip STP learning for end-device ports
Switch(config-if)# spanning-tree portfast

! BPDU Guard — shutdown port if BPDU received (connected switch)
Switch(config-if)# spanning-tree bpduguard enable

! Root Guard — prevent port from becoming root port
Switch(config-if)# spanning-tree guard root

! Loop Guard — prevent transition to forwarding if BPDUs stop arriving
Switch(config-if)# spanning-tree guard loop

! Enable globally for all PortFast ports
Switch(config)# spanning-tree portfast bpduguard default
```

---

## 6. VPNs

**VPNs (Virtual Private Networks)** create encrypted tunnels over untrusted networks (internet).

### Site-to-Site VPN

Connects entire networks over the internet. The VPN gateway (router/firewall) handles encryption, transparent to end users.

```
SITE-TO-SITE VPN:
────────────────────────────────────────────────────────────────────
Office A                    INTERNET               Office B
192.168.1.0/24                                 192.168.2.0/24

[PC]──[R1: 203.0.113.1]═══ Encrypted Tunnel ══[R2: 203.0.113.2]──[PC]

Traffic from PC-A to PC-B is encrypted in the tunnel.
Neither PC is aware of the VPN — it's transparent.
```

### Remote Access VPN

Individual users connect to corporate network from remote locations.

```
REMOTE ACCESS VPN:
────────────────────────────────────────────────────────────────────
                                   Corporate Network
Home User                          192.168.1.0/24
[Laptop]═══ SSL/IPsec VPN ══[VPN Gateway]──[Servers]
(VPN Client software)

Laptop gets a virtual IP from corporate space.
All traffic routed through the VPN.
```

### IPsec VPN

**IPsec (IP Security)** is a protocol suite for secure IP communications.

```
IPsec operates at Layer 3. Two main protocols:
  AH  (Authentication Header)   — integrity + authentication (no encryption)
  ESP (Encapsulating Security Payload) — integrity + auth + ENCRYPTION (use this)

Two modes:
  Transport mode — encrypts payload only (header exposed). Used for host-to-host.
  Tunnel mode    — encrypts entire packet + adds new IP header. Used for site-to-site.
```

**IKE (Internet Key Exchange)** — negotiates security associations (SAs):
- **Phase 1** — Authenticate VPN peers, establish secure channel
- **Phase 2** — Negotiate IPsec parameters (ESP/AH, encryption, auth)

### SSL/TLS VPN

- Runs over HTTPS (TCP 443)
- No special client needed (browser-based) for clientless
- Or thin client (Cisco AnyConnect)
- Easier through firewalls than IPsec
- Cisco SSL VPN → **Cisco AnyConnect** (uses TLS)

### GRE Tunnel

**GRE (Generic Routing Encapsulation)** — not encrypted by itself, but creates a logical point-to-point link for routing. Often combined with IPsec for encryption.

```
! GRE Tunnel Configuration
Router(config)# interface Tunnel0
Router(config-if)# ip address 172.16.1.1 255.255.255.252    ! tunnel IP
Router(config-if)# tunnel source GigabitEthernet0/1          ! physical WAN interface
Router(config-if)# tunnel destination 203.0.113.2            ! remote router public IP

! Run OSPF or static routes over the tunnel
Router(config)# router ospf 1
Router(config-router)# network 172.16.1.0 0.0.0.3 area 0
```

---

## 7. AAA (Authentication, Authorization, Accounting)

**AAA** is a security framework for controlling access to network devices.

| Component | What it does | Example |
|-----------|-------------|---------|
| **Authentication** | Who are you? | Username + Password |
| **Authorization** | What can you do? | Admin can configure, operator can only view |
| **Accounting** | What did you do? | Logs commands, session times |

### RADIUS vs TACACS+

| Feature | RADIUS | TACACS+ |
|---------|--------|---------|
| Standard | Open (RFC) | Cisco proprietary |
| Protocol | UDP 1812/1813 | TCP 49 |
| Encryption | Encrypts password only | Encrypts entire payload |
| AAA | Combined auth/author | Separates auth, author, acct |
| Best for | Network Access (802.1X, VPN) | Device Administration |

> **Exam Tip:** RADIUS is common for network access (Wi-Fi, VPN). TACACS+ is preferred for device administration (SSH to routers/switches) because it separates authorization.

### AAA Configuration

```
! Enable AAA
Router(config)# aaa new-model          ! enables AAA (overrides line-level auth)

! Configure RADIUS server
Router(config)# radius server RADIUS1
Router(config-radius-server)# address ipv4 10.1.1.200 auth-port 1812 acct-port 1813
Router(config-radius-server)# key RADIUS-Secret-Key
Router(config-radius-server)# exit

! Configure TACACS+ server
Router(config)# tacacs server TACACS1
Router(config-server-tacacs)# address ipv4 10.1.1.201
Router(config-server-tacacs)# key TACACS-Secret-Key
Router(config-server-tacacs)# exit

! Define method lists
! Authentication: try TACACS+ first, then local DB as fallback
Router(config)# aaa authentication login default group tacacs+ local

! Authorization: use TACACS+ for exec (shell) access
Router(config)# aaa authorization exec default group tacacs+ local

! Accounting: log commands to TACACS+
Router(config)# aaa accounting exec default start-stop group tacacs+
Router(config)# aaa accounting commands 15 default start-stop group tacacs+

! Apply to VTY lines
Router(config)# line vty 0 15
Router(config-line)# login authentication default   ! use default method list

! Verify
Router# show aaa servers
Router# debug aaa authentication
```

---

## 8. Wireless Security Protocols

### Evolution (recap from Chapter 2)

| Protocol | Encryption | Auth | Notes |
|----------|-----------|------|-------|
| **WEP** | RC4 (40/104-bit) | Shared key | Broken — never use |
| **WPA** | TKIP | PSK/802.1X | Weak — avoid |
| **WPA2** | AES-CCMP | PSK/802.1X | Current standard |
| **WPA3** | AES-GCMP-256 | SAE/802.1X | Best — use when possible |

### WPA3 Improvements Over WPA2

- **SAE (Simultaneous Authentication of Equals)** — replaces PSK, prevents offline dictionary attacks
- **Forward secrecy** — compromised password doesn't expose past traffic
- **192-bit security mode** — for enterprise (WPA3-Enterprise)
- **Enhanced Open** — encryption on open networks (opportunistic wireless encryption)

### EAP Methods (for WPA2/WPA3-Enterprise)

| EAP Type | Client Auth | Server Auth | Notes |
|----------|------------|------------|-------|
| **EAP-TLS** | Certificate | Certificate | Strongest, requires PKI |
| **PEAP** | MSCHAPv2 | Certificate | Common, easier to deploy |
| **EAP-FAST** | PAC | Optional cert | Cisco, no certificate required |
| **EAP-TTLS** | Various | Certificate | Flexible |

### Wireless Threat Mitigation

| Threat | Mitigation |
|--------|-----------|
| **Evil Twin** (rogue AP) | WPA2-Enterprise (RADIUS auth), WIPS |
| **Deauth attacks** | WPA3 (management frame protection - 802.11w) |
| **Weak passwords** | WPA3-SAE or strong WPA2 passphrase |
| **Sniffing** | WPA2/WPA3 encryption |
| **Rogue AP** | Wireless IPS (WIPS), 802.1X on wired ports |

---

## Chapter 5 Summary

| Topic | Key Points |
|-------|-----------|
| CIA Triad | Confidentiality, Integrity, Availability |
| Device hardening | Enable secret, SSH, disable unused services, banners |
| Standard ACLs | Match source IP only, place near destination, ACL 1-99 |
| Extended ACLs | Match src+dst+protocol+port, place near source, ACL 100-199 |
| Wildcard masks | Inverse of subnet mask, 0=must match, 1=any |
| Port security | Limit MACs per port, violation modes (shutdown/restrict/protect) |
| DHCP Snooping | Trusted (toward DHCP server) vs untrusted ports |
| DAI | Validates ARP against DHCP binding table |
| VPNs | Site-to-site vs remote access, IPsec vs SSL/TLS |
| AAA | RADIUS (UDP, network access), TACACS+ (TCP, device admin) |
| Wireless | WPA2 minimum, WPA3 preferred, PSK vs Enterprise (802.1X) |

---

*[← Chapter 4](04-ip-services.md) | [Chapter 6: Automation →](06-automation.md)*
