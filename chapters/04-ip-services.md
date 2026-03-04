# Chapter 4: IP Services

> **Exam Weight: 10%**

---

## Table of Contents
1. [DHCP](#1-dhcp)
2. [DNS](#2-dns)
3. [NAT and PAT](#3-nat-and-pat)
4. [NTP](#4-ntp)
5. [SNMP](#5-snmp)
6. [Syslog](#6-syslog)
7. [QoS Fundamentals](#7-qos-fundamentals)
8. [SSH Remote Access](#8-ssh-remote-access)
9. [FTP and TFTP](#9-ftp-and-tftp)

---

## 1. DHCP

**DHCP (Dynamic Host Configuration Protocol)** automatically assigns IP configuration to hosts. Uses UDP ports **67** (server) and **68** (client).

### DHCP DORA Process

```
CLIENT                          DHCP SERVER
   │                                │
   │──DISCOVER──(broadcast)────────→│  "Is there a DHCP server?"
   │                                │
   │←─OFFER─────(unicast/bcast)─────│  "Here's an IP offer: 10.1.1.50"
   │                                │
   │──REQUEST───(broadcast)────────→│  "I accept 10.1.1.50"
   │                                │
   │←─ACK───────(unicast/bcast)─────│  "Confirmed — it's yours for X hours"
   │                                │
   │   [Client uses IP address]     │

D = Discover (broadcast — client doesn't have IP yet)
O = Offer    (server offers IP)
R = Request  (client formally requests the offered IP)
A = Acknowledge (server confirms)
```

### Configuring a Cisco Router as DHCP Server

```
! Exclude addresses from DHCP pool (reserved for routers, printers, etc.)
Router(config)# ip dhcp excluded-address 10.1.1.1 10.1.1.10

! Create DHCP pool
Router(config)# ip dhcp pool LAN-POOL
Router(dhcp-config)# network 10.1.1.0 255.255.255.0    ! subnet to serve
Router(dhcp-config)# default-router 10.1.1.1            ! default gateway
Router(dhcp-config)# dns-server 8.8.8.8 8.8.4.4        ! DNS servers
Router(dhcp-config)# domain-name company.local          ! DNS domain
Router(dhcp-config)# lease 7                            ! lease time in days (default 1)
Router(dhcp-config)# exit

! Create another pool for a different subnet
Router(config)# ip dhcp pool VLAN20-POOL
Router(dhcp-config)# network 192.168.20.0 255.255.255.0
Router(dhcp-config)# default-router 192.168.20.1
Router(dhcp-config)# dns-server 8.8.8.8
Router(dhcp-config)# exit

! Verify DHCP
Router# show ip dhcp binding                ! see all IP assignments

IP address       Client-ID/              Lease expiration        Type
                 Hardware address/
                 User name
10.1.1.11        aabb.cc00.0100          Mar 10 2026 08:00 AM    Automatic
10.1.1.12        aabb.cc00.0200          Mar 10 2026 08:00 AM    Automatic

Router# show ip dhcp pool                  ! show pool stats
Router# show ip dhcp conflict              ! IPs that caused conflicts
Router# debug ip dhcp server events        ! live DHCP debugging (careful in prod)

! Configure a router as DHCP client on an interface
Router(config-if)# ip address dhcp
```

### DHCP Relay Agent (ip helper-address)

When the DHCP server is on a different subnet, the router's DHCP broadcasts don't cross routers. A **relay agent** (ip helper-address) forwards the broadcast as a unicast to the DHCP server.

```
TOPOLOGY:
──────────────────────────────────────────────────────────────────
[Client]──[SW]──[R1 Gi0/0: 10.1.1.1]──[R1 Gi0/1: 10.2.2.1]──[DHCP Server: 10.2.2.10]

The client broadcasts DHCP Discover on 10.1.1.0/24.
R1 needs to forward it to 10.2.2.10.
──────────────────────────────────────────────────────────────────

! Configure ip helper-address on the interface facing the clients
R1(config)# interface GigabitEthernet0/0
R1(config-if)# ip helper-address 10.2.2.10    ! forward DHCP broadcasts here

! Multiple DHCP servers (high availability)
R1(config-if)# ip helper-address 10.2.2.10
R1(config-if)# ip helper-address 10.2.2.11

! ip helper-address also forwards these UDP broadcasts:
! - TFTP (69), DNS (53), BOOTP (67/68), TACACS (49), Time (37)
```

> **Exam Tip:** `ip helper-address` is configured on the **router interface facing the clients** — NOT on the interface facing the DHCP server.

---

## 2. DNS

**DNS (Domain Name System)** resolves human-readable names to IP addresses. Uses port **53** (UDP for queries, TCP for zone transfers).

### DNS Resolution Process

```
CLIENT                  LOCAL DNS          ROOT DNS      .com TLD DNS    cisco.com DNS
   │                     SERVER             SERVER          SERVER           SERVER
   │                        │                  │               │                │
   │─ Query: cisco.com? ───→│                  │               │                │
   │                        │─ Root referral? ─→│               │                │
   │                        │←─ Ask .com TLD ──│               │                │
   │                        │─ cisco.com? ──────────────────→│  │                │
   │                        │←─ Ask cisco.com DNS ────────────│               │
   │                        │─ cisco.com A? ────────────────────────────────→│
   │                        │←─ 104.16.xx.xx ──────────────────────────────│
   │←─ 104.16.xx.xx ────────│
   │   [cache result]       │

Recursive resolution: Local DNS does all the work for the client
Iterative resolution: Each server tells the client where to ask next
```

### DNS Record Types

| Record | Purpose | Example |
|--------|---------|---------|
| **A** | IPv4 address | `cisco.com → 104.16.1.1` |
| **AAAA** | IPv6 address | `cisco.com → 2001:DB8::1` |
| **CNAME** | Alias/canonical name | `www.cisco.com → cisco.com` |
| **MX** | Mail server | `cisco.com → mail.cisco.com` |
| **NS** | Name server | Authoritative DNS servers |
| **PTR** | Reverse lookup | `104.16.1.1 → cisco.com` |
| **SOA** | Start of authority | Zone info, serial number |
| **TXT** | Text records | SPF, DKIM, domain verification |

### Configuring DNS on Cisco Router

```
! Configure the router to use external DNS servers
Router(config)# ip name-server 8.8.8.8 8.8.4.4

! Enable domain lookup (enabled by default)
Router(config)# ip domain-lookup

! Set domain name for DNS searches
Router(config)# ip domain-name company.local

! Use router as DNS server for clients (simple internal DNS)
Router(config)# ip dns server

! Add static DNS entries
Router(config)# ip host SERVER1 10.1.1.20
Router(config)# ip host SERVER2 10.1.1.21

! Verify
Router# show hosts
Router# nslookup cisco.com    ! DNS lookup test

! Disable DNS lookup (prevents typos from causing 30s delay in CLI)
Router(config)# no ip domain-lookup
```

---

## 3. NAT and PAT

**NAT (Network Address Translation)** translates private IP addresses to public IPs (and vice versa). Needed because private IP space is not routable on the internet.

### NAT Terminology

```
INSIDE LOCAL:    Private IP of inside host (before translation)
INSIDE GLOBAL:   Public IP of inside host (after translation) — what internet sees
OUTSIDE LOCAL:   IP of external host as seen from inside network
OUTSIDE GLOBAL:  Actual IP of external host

Most common scenario:
  Inside Local:  192.168.1.10  (PC behind NAT)
  Inside Global: 203.0.113.5   (public IP assigned by ISP)
  Outside Global: 8.8.8.8      (Google's DNS)
```

### Types of NAT

**Static NAT** — 1:1 mapping. One private IP always maps to one public IP. Used for servers that need a consistent public IP.

```
! Static NAT — map private 10.1.1.10 to public 203.0.113.10
Router(config)# ip nat inside source static 10.1.1.10 203.0.113.10

! Mark interfaces
Router(config)# interface GigabitEthernet0/0      ! LAN interface
Router(config-if)# ip nat inside
Router(config-if)# exit

Router(config)# interface GigabitEthernet0/1      ! WAN interface
Router(config-if)# ip nat outside
Router(config-if)# exit
```

**Dynamic NAT** — Pool of public IPs. Inside hosts get a public IP from the pool when needed. Not scalable (one public IP per session).

```
! Create pool of public IPs
Router(config)# ip nat pool PUBLIC-POOL 203.0.113.10 203.0.113.20 netmask 255.255.255.0

! Create ACL to match inside hosts to translate
Router(config)# ip access-list standard NAT-HOSTS
Router(config-std-nacl)# permit 10.1.1.0 0.0.0.255
Router(config-std-nacl)# exit

! Apply NAT — source ACL mapped to pool
Router(config)# ip nat inside source list NAT-HOSTS pool PUBLIC-POOL
```

**PAT (Port Address Translation) / NAT Overload** — Many private IPs share ONE public IP. The router tracks connections using port numbers. This is what most home/office routers use.

```
! PAT using a pool
Router(config)# ip access-list standard PAT-HOSTS
Router(config-std-nacl)# permit 192.168.0.0 0.0.255.255
Router(config-std-nacl)# exit

Router(config)# ip nat pool PAT-POOL 203.0.113.5 203.0.113.5 netmask 255.255.255.0
Router(config)# ip nat inside source list PAT-HOSTS pool PAT-POOL overload

! PAT using the WAN interface IP (most common — dynamic ISP IP)
Router(config)# ip nat inside source list PAT-HOSTS interface GigabitEthernet0/1 overload

! Mark inside and outside interfaces
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ip nat inside
Router(config)# interface GigabitEthernet0/1
Router(config-if)# ip nat outside
```

### NAT Verification

```
! Show active NAT translations
Router# show ip nat translations

Pro Inside global      Inside local       Outside local      Outside global
tcp 203.0.113.5:1024  192.168.1.10:1024  8.8.8.8:53        8.8.8.8:53
tcp 203.0.113.5:1025  192.168.1.11:2048  8.8.4.4:80        8.8.4.4:80
--- 203.0.113.10      10.1.1.10          ---               ---    ← static NAT

! Show NAT statistics
Router# show ip nat statistics

Total active translations: 2 (1 static, 1 dynamic; 1 extended)
Outside interfaces:
  GigabitEthernet0/1
Inside interfaces:
  GigabitEthernet0/0
Hits: 152  Misses: 5
Expired translations: 3
Dynamic mappings:
  ...

! Clear NAT translations
Router# clear ip nat translation *          ! clear all dynamic
Router# clear ip nat translation inside 203.0.113.5 192.168.1.10    ! clear specific
```

> **Exam Tip:** Know the difference between inside/outside and local/global. The key: "local" = as seen from INSIDE, "global" = as seen from OUTSIDE (internet). Static NAT = 1:1, PAT = many:1 using ports.

---

## 4. NTP

**NTP (Network Time Protocol)** synchronizes clocks across network devices. Uses **UDP port 123**. Accurate time is critical for:
- Log correlation
- Certificate validity
- Security protocols (Kerberos, etc.)

### NTP Stratum Levels

```
STRATUM 0:  Atomic clocks, GPS receivers — reference clocks
STRATUM 1:  NTP servers directly connected to stratum 0 (very accurate)
STRATUM 2:  NTP servers synchronized to stratum 1
STRATUM 3:  NTP servers synchronized to stratum 2
...
STRATUM 15: Maximum usable stratum
STRATUM 16: Unsynchronized (clock not synced)

Each hop from reference clock adds 1 stratum level.
```

### NTP Configuration

```
! Configure as NTP client (sync to external server)
Router(config)# ntp server 216.239.35.0          ! Google NTP
Router(config)# ntp server 216.239.35.4          ! secondary

! Configure as NTP server for other devices
! (Once synced to external, automatically becomes server for others)

! Specify NTP server as preferred
Router(config)# ntp server 216.239.35.0 prefer

! Set timezone
Router(config)# clock timezone EST -5
Router(config)# clock summer-time EDT recurring

! Configure NTP master (act as authoritative even without external sync)
! Use with caution — lab/isolated environments
Router(config)# ntp master 3        ! stratum 3

! Configure NTP authentication (recommended)
Router(config)# ntp authenticate
Router(config)# ntp authentication-key 1 md5 NTPkey123
Router(config)# ntp trusted-key 1
Router(config)# ntp server 216.239.35.0 key 1

! Verify NTP
Router# show ntp status

Clock is synchronized, stratum 3, reference is 216.239.35.0
nominal freq is 250.0000 Hz, actual freq is 250.0001 Hz, precision is 2**18
ntp uptime is 3600 (1/100 of seconds), resolution is 4000
reference time is E7B8D200.00000000 (08:00:00.000 UTC Mon Mar 3 2026)
clock offset is 0.3 msec, root delay is 2.50 msec
root dispersion is 7.50 msec, peer dispersion is 0.15 msec
loopfilter state is 'CTRL' (Normal Controlled Loop), drift is 0.000002 s/s
system poll interval is 64, last update was 32 sec ago.

Router# show ntp associations

  address         ref clock       st   when     poll    reach  delay    offset   disp
*~216.239.35.0   .GOOG.           1     45       64      377    2.50     0.30    0.15
 ~216.239.35.4   .GOOG.           1     50       64      377    3.10     0.25    0.20

* = current sync source
~ = configured peer
```

---

## 5. SNMP

**SNMP (Simple Network Management Protocol)** allows monitoring and management of network devices. Uses **UDP ports 161** (polling) and **162** (traps).

### SNMP Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    NMS (Network Management System)           │
│              Polls devices, receives traps                   │
│              Software: SolarWinds, PRTG, Nagios, Cisco DNA   │
└─────────────────────┬───────────────────────────────────────┘
                      │ SNMP messages (UDP 161/162)
         ┌────────────┼────────────────┐
    ┌────┴────┐  ┌────┴────┐  ┌────┴────┐
    │ Router  │  │ Switch  │  │ Server  │
    │(Agent)  │  │(Agent)  │  │(Agent)  │
    │  MIB    │  │  MIB    │  │  MIB    │
    └─────────┘  └─────────┘  └─────────┘

MIB = Management Information Base (database of manageable objects)
OID = Object Identifier (unique ID for each MIB variable)
```

### SNMP Operations

| Operation | Direction | Description |
|-----------|-----------|-------------|
| **Get** | NMS → Agent | Request single value |
| **GetNext** | NMS → Agent | Request next OID in MIB tree |
| **GetBulk** | NMS → Agent | Request multiple values (v2c+) |
| **Set** | NMS → Agent | Change a value on device |
| **Trap** | Agent → NMS | Unsolicited notification |
| **Inform** | Agent → NMS | Trap with acknowledgment (v2c+) |

### SNMP Versions

| Version | Security | Notes |
|---------|----------|-------|
| **SNMPv1** | Community strings (cleartext) | Legacy, avoid |
| **SNMPv2c** | Community strings (cleartext) | Adds GetBulk, Inform |
| **SNMPv3** | Auth + Encryption | Use this — enterprise standard |

### SNMPv2c Configuration

```
! Configure SNMP community strings
Router(config)# snmp-server community PUBLIC ro           ! read-only (monitoring)
Router(config)# snmp-server community PRIVATE rw          ! read-write (management)

! Restrict SNMP access to specific NMS hosts
Router(config)# ip access-list standard SNMP-ACL
Router(config-std-nacl)# permit 10.1.1.100              ! NMS server IP
Router(config-std-nacl)# exit

Router(config)# snmp-server community PUBLIC ro SNMP-ACL  ! apply ACL

! Configure SNMP traps (send to NMS)
Router(config)# snmp-server host 10.1.1.100 version 2c PUBLIC
Router(config)# snmp-server enable traps                  ! enable all traps
! Or specific traps:
Router(config)# snmp-server enable traps snmp linkup linkdown
Router(config)# snmp-server enable traps ospf

! Set device identity for SNMP
Router(config)# snmp-server location "Server Room, Rack 3"
Router(config)# snmp-server contact "admin@company.com"
```

### SNMPv3 Configuration

```
! SNMPv3 uses Users, not community strings
! Security levels: noAuthNoPriv, authNoPriv, authPriv

! Create SNMPv3 user with authentication and encryption
Router(config)# snmp-server group MGMT-GROUP v3 priv     ! group using privacy
Router(config)# snmp-server user ADMIN MGMT-GROUP v3 \
  auth sha AuthPassword123 \
  priv aes 128 PrivPassword456

! Configure trap target for SNMPv3
Router(config)# snmp-server host 10.1.1.100 version 3 priv ADMIN

! Verify SNMP
Router# show snmp
Router# show snmp community
Router# show snmp user
```

---

## 6. Syslog

**Syslog** is the standard for system logging. Devices send log messages to a syslog server. Uses **UDP port 514**.

### Syslog Severity Levels

> Mnemonic: **"Every Awesome Cisco Engineer Will Need Daily Practice"**

| Level | Keyword | Description |
|-------|---------|-------------|
| 0 | **Emergencies** | System unstable |
| 1 | **Alerts** | Immediate action needed |
| 2 | **Critical** | Critical conditions |
| 3 | **Errors** | Error conditions |
| 4 | **Warnings** | Warning conditions |
| 5 | **Notifications** | Normal but significant |
| 6 | **Informational** | Informational messages |
| 7 | **Debugging** | Debugging messages |

Setting a level includes that level **and all higher severity (lower number)** levels.

### Syslog Configuration

```
! Send logs to syslog server
Router(config)# logging host 10.1.1.100        ! syslog server IP

! Set minimum severity to log (sends levels 0-3 to server)
Router(config)# logging trap errors            ! or use number: logging trap 3

! Set buffer logging (stored in RAM)
Router(config)# logging buffered 64000         ! buffer size in bytes
Router(config)# logging buffered informational  ! level 6 and above

! Enable console logging
Router(config)# logging console warnings        ! level 4 and above

! Add timestamps to logs (strongly recommended)
Router(config)# service timestamps log datetime msec

! Set source interface for syslog
Router(config)# logging source-interface Loopback0

! Verify
Router# show logging

Syslog logging: enabled (11 messages dropped, 0 flushes, 0 overruns)
    Console logging: level warnings, 10 messages logged
    Monitor logging: level debugging, 0 messages logged
    Buffer logging: level informational, 25 messages logged
    Trap logging: level errors, 30 message lines logged
        Logging to 10.1.1.100 (udp port 514), 28 messages logged

Log Buffer (64000 bytes):
*Mar  3 08:00:01.123: %LINK-3-UPDOWN: Interface GigabitEthernet0/0, changed state to up
*Mar  3 08:00:03.456: %OSPF-5-ADJCHG: Process 1, Nbr 2.2.2.2 on Gi0/0 from LOADING to FULL
```

### Syslog Message Format

```
%FACILITY-SEVERITY-MNEMONIC: description

Example:
%OSPF-5-ADJCHG: Process 1, Nbr 2.2.2.2 on Gi0/0 from LOADING to FULL

│ OSPF   = Facility (which process generated the message)
│ 5      = Severity (5 = Notification)
│ ADJCHG = Mnemonic (short identifier)
│ description = Human-readable explanation
```

---

## 7. QoS Fundamentals

**QoS (Quality of Service)** prioritizes certain traffic types to ensure good performance for time-sensitive applications (VoIP, video).

### Why QoS?

```
WITHOUT QoS:             WITH QoS:
──────────────────        ──────────────────────────────
[VoIP] ──────────→        [VoIP] ──→ HIGH PRIORITY ──→ forwarded first
[Video] ─────────→        [Video] ─→ MEDIUM PRIORITY ──→ forwarded second
[Data] ──────────→        [Data] ──→ LOW PRIORITY ────→ forwarded third
  All treated equally        Time-sensitive traffic protected
```

### QoS Key Concepts

**Classification** — Identify traffic (what type is this?)
- By DSCP/IP Precedence bits in IP header
- By port numbers, protocol, ACL matches
- NBAR (Network-Based Application Recognition)

**Marking** — Tag traffic for easier identification at subsequent hops
- **DSCP** (Differentiated Services Code Point) — 6-bit field in IP header
- **CoS** (Class of Service) — 3-bit field in 802.1Q tag (Layer 2)
- **IP Precedence** — first 3 bits of ToS byte (older)

### DSCP Common Values

| DSCP Value | Binary | Traffic Type | Notes |
|-----------|--------|--------------|-------|
| EF (46) | 101110 | VoIP RTP | Expedited Forwarding — lowest latency |
| AF41 (34) | 100010 | Video conf | Assured Forwarding class 4, drop pref 1 |
| AF31 (26) | 011010 | Call signaling | |
| AF21 (18) | 010010 | Transactional | |
| AF11 (10) | 001010 | Bulk data | |
| CS0 (0) | 000000 | Default/best effort | |

**Queuing** — Control order of transmission
- **FIFO** — first in, first out (no QoS)
- **PQ** (Priority Queuing) — strict priority for highest class
- **CBWFQ** (Class-Based Weighted Fair Queuing) — guaranteed bandwidth per class
- **LLQ** (Low-Latency Queuing) — CBWFQ + strict priority queue for voice

**Congestion Avoidance**
- **WRED** (Weighted Random Early Detection) — drops low-priority packets before queue fills to avoid TCP global synchronization

**Policing and Shaping**
- **Policing** — drops or re-marks excess traffic (can cause drops)
- **Shaping** — buffers excess traffic, sending at defined rate (smoother, delays)

```
! Basic QoS Classification and Marking
! Step 1: Create class maps to classify traffic
Router(config)# class-map match-any VOICE
Router(config-cmap)# match ip dscp ef             ! match EF-marked voice
Router(config-cmap)# exit

Router(config)# class-map match-any VIDEO
Router(config-cmap)# match ip dscp af41           ! match AF41 video
Router(config-cmap)# exit

! Step 2: Create policy map to define actions
Router(config)# policy-map QOS-POLICY
Router(config-pmap)# class VOICE
Router(config-pmap-c)# priority 500               ! strict priority, 500 kbps
Router(config-pmap-c)# exit
Router(config-pmap)# class VIDEO
Router(config-pmap-c)# bandwidth 1000             ! guaranteed 1 Mbps
Router(config-pmap-c)# exit
Router(config-pmap)# class class-default
Router(config-pmap-c)# fair-queue                 ! WFQ for everything else
Router(config-pmap-c)# exit

! Step 3: Apply to interface
Router(config)# interface GigabitEthernet0/1
Router(config-if)# service-policy output QOS-POLICY   ! apply outbound
```

> **Exam Tip:** For CCNA, understand the QoS model conceptually — classification, marking, queuing, congestion management. Know DSCP EF is for voice (lowest latency) and understand policing vs shaping.

---

## 8. SSH Remote Access

**SSH (Secure Shell)** provides encrypted remote access. Replaces insecure Telnet. Uses **TCP port 22**.

### Telnet vs SSH

| Feature | Telnet | SSH |
|---------|--------|-----|
| Port | 23 | 22 |
| Encryption | None | Yes (encrypted) |
| Authentication | Password | Password or public key |
| Security | Insecure — never use | Secure — use this |

### SSH Configuration

```
! Prerequisites for SSH:
! 1. Set hostname (not default "Router")
! 2. Set domain name
! 3. Generate RSA key pair
! 4. Create local user account
! 5. Configure VTY lines to use SSH

! Step 1: Set hostname
Router(config)# hostname R1

! Step 2: Set domain name (required for RSA key generation)
R1(config)# ip domain-name company.local

! Step 3: Generate RSA keys (minimum 1024 bits, recommend 2048)
R1(config)# crypto key generate rsa modulus 2048
% The name for the keys will be: R1.company.local
% Generating 2048 bit RSA keys, keys will be non-exportable...
[OK] (elapsed time was 3 seconds)

! Step 4: Create local user
R1(config)# username admin privilege 15 secret StrongPass123

! Step 5: Configure VTY lines for SSH only
R1(config)# line vty 0 15
R1(config-line)# transport input ssh          ! SSH only (not Telnet)
R1(config-line)# login local                  ! use local user database
R1(config-line)# exec-timeout 10 0            ! 10 minute timeout
R1(config-line)# exit

! Set SSH version 2
R1(config)# ip ssh version 2
R1(config)# ip ssh time-out 60               ! SSH negotiation timeout
R1(config)# ip ssh authentication-retries 3  ! max auth attempts

! Optional: Configure console line for security
R1(config)# line console 0
R1(config-line)# login local
R1(config-line)# exec-timeout 5 0
R1(config-line)# exit

! Set enable password/secret
R1(config)# enable secret SuperSecret456

! Verify SSH
R1# show ip ssh

SSH Enabled - version 2.0
Authentication timeout: 60 secs; Authentication retries: 3
Minimum expected Diffie Hellman key size : 1024 bits

R1# show ssh

Connection Version Mode Encryption  Hmac         State          Username
0          2.0     IN   aes256-cbc   hmac-sha2-256 Session started admin
```

### Connecting via SSH

```
! Connect to R1 from another Cisco device
Router# ssh -l admin -p 22 192.168.1.1

! Or using shortened syntax
Router# ssh admin@192.168.1.1
```

---

## 9. FTP and TFTP

Both are used for file transfer to/from network devices (IOS images, configs).

### TFTP (Trivial File Transfer Protocol)

- **Port:** UDP 69
- **No authentication**
- **Unreliable** — uses UDP (application layer handles errors)
- Used for: IOS upgrades, config backup/restore in lab/simple environments

```
! Copy running config to TFTP server
Router# copy running-config tftp:
Address or name of remote host []? 10.1.1.100
Destination filename [router-confg]? R1-backup.cfg
!!
1234 bytes copied in 1.234 secs (1000 bytes/sec)

! Copy IOS image from TFTP to flash
Router# copy tftp: flash:
Address or name of remote host []? 10.1.1.100
Source filename []? c1900-universalk9-mz.SPA.158-3.M2.bin
Destination filename [c1900-universalk9-mz.SPA.158-3.M2.bin]?
!!!...
[OK - 73684000 bytes]

! Restore config from TFTP
Router# copy tftp: running-config
Address or name of remote host []? 10.1.1.100
Source filename []? R1-backup.cfg
!!
1234 bytes copied in 0.534 secs
```

### FTP (File Transfer Protocol)

- **Ports:** TCP 20 (data), TCP 21 (control)
- **With authentication** (username/password)
- **Reliable** — uses TCP
- Better for larger files, more secure than TFTP

```
! Set FTP credentials
Router(config)# ip ftp username ftpuser
Router(config)# ip ftp password ftppass

! Copy config to FTP server
Router# copy running-config ftp:
Address or name of remote host []? 10.1.1.100
Destination filename [router-confg]? R1-backup.cfg

! Copy IOS from FTP
Router# copy ftp://ftpuser:ftppass@10.1.1.100/ios/c1900-image.bin flash:
```

| Feature | TFTP | FTP |
|---------|------|-----|
| Port | UDP 69 | TCP 20/21 |
| Authentication | None | Yes |
| Reliability | UDP (unreliable) | TCP (reliable) |
| Use case | Simple lab transfers | Production file transfers |
| Firewall friendly | Simpler | More complex (passive mode) |

---

## Chapter 4 Summary

| Service | Port | Protocol | Key Points |
|---------|------|----------|-----------|
| DHCP | 67/68 | UDP | DORA process, ip helper-address for relay |
| DNS | 53 | UDP/TCP | A/AAAA/CNAME/MX records, hierarchical |
| NAT | — | — | Static (1:1), Dynamic (pool), PAT (overload) |
| NTP | 123 | UDP | Stratum levels, sync client to server |
| SNMP | 161/162 | UDP | v2c community strings, v3 auth+encryption |
| Syslog | 514 | UDP | 8 levels (0-7), configure logging host |
| SSH | 22 | TCP | Needs RSA keys + hostname + domain name |
| TFTP | 69 | UDP | No auth, simple transfers |
| FTP | 20/21 | TCP | Auth, reliable, larger files |

---

*[← Chapter 3](03-ip-connectivity.md) | [Chapter 5: Security Fundamentals →](05-security.md)*
