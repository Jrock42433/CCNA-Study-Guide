# Chapter 1: Network Fundamentals

> **Exam Weight: 20%**

---

## Table of Contents
1. [OSI Reference Model](#1-osi-reference-model)
2. [TCP/IP Model](#2-tcpip-model)
3. [Network Topologies](#3-network-topologies)
4. [Physical Media and Cabling](#4-physical-media-and-cabling)
5. [Network Devices](#5-network-devices)
6. [IPv4 Addressing](#6-ipv4-addressing)
7. [Subnetting](#7-subnetting)
8. [VLSM](#8-vlsm---variable-length-subnet-masking)
9. [IPv6 Addressing](#9-ipv6-addressing)
10. [TCP vs UDP](#10-tcp-vs-udp)
11. [Common Ports and Protocols](#11-common-ports-and-protocols)
12. [Switching Fundamentals](#12-switching-fundamentals)

---

## 1. OSI Reference Model

The **Open Systems Interconnection (OSI)** model is a 7-layer framework that describes how data travels from one device to another across a network. Each layer has a specific job and communicates with the layers directly above and below it.

### Mnemonic
- **Top to bottom (7→1):** "**A**ll **P**eople **S**eem **T**o **N**eed **D**ata **P**rocessing"
- **Bottom to top (1→7):** "**P**lease **D**o **N**ot **T**hrow **S**ausage **P**izza **A**way"

```
┌─────────────────────────────────────────────────────────────────┐
│  Layer 7 │ APPLICATION  │ HTTP, FTP, DNS, SMTP, Telnet, SSH     │
├─────────────────────────────────────────────────────────────────┤
│  Layer 6 │ PRESENTATION │ SSL/TLS, JPEG, MPEG, ASCII, Encrypt   │
├─────────────────────────────────────────────────────────────────┤
│  Layer 5 │ SESSION      │ NetBIOS, SQL sessions, RPC, PPTP      │
├─────────────────────────────────────────────────────────────────┤
│  Layer 4 │ TRANSPORT    │ TCP, UDP — Segments                   │
├─────────────────────────────────────────────────────────────────┤
│  Layer 3 │ NETWORK      │ IP, ICMP, ARP* — Packets             │
├─────────────────────────────────────────────────────────────────┤
│  Layer 2 │ DATA LINK    │ Ethernet, 802.11, PPP — Frames        │
├─────────────────────────────────────────────────────────────────┤
│  Layer 1 │ PHYSICAL     │ Cables, hubs, bits — Bits             │
└─────────────────────────────────────────────────────────────────┘
```

### PDUs (Protocol Data Units) per Layer

| Layer | PDU Name | Key Info |
|-------|----------|----------|
| 4 - Transport | **Segment** | TCP/UDP, port numbers |
| 3 - Network | **Packet** | IP addresses (src/dst) |
| 2 - Data Link | **Frame** | MAC addresses (src/dst) |
| 1 - Physical | **Bit** | Electrical/optical signals |

### Layer Details

**Layer 7 – Application**
The layer end-users interact with. Provides network services to applications.
Protocols: HTTP (80), HTTPS (443), FTP (20/21), SSH (22), Telnet (23), DNS (53), SMTP (25), POP3 (110), IMAP (143), SNMP (161)

**Layer 6 – Presentation**
Translates data formats, handles encryption/decryption, and compression.
Think: translator between application and network.

**Layer 5 – Session**
Establishes, manages, and terminates sessions (conversations) between applications.

**Layer 4 – Transport**
Provides reliable (TCP) or unreliable (UDP) end-to-end data delivery. Uses port numbers to identify services.
- **TCP** — Connection-oriented, reliable, ordered, error-checked
- **UDP** — Connectionless, fast, no guaranteed delivery

**Layer 3 – Network**
Handles logical addressing (IP) and routing between networks. Routers operate here.

**Layer 2 – Data Link**
Handles physical addressing (MAC addresses) and access to the physical medium. Switches operate here.
- **LLC** (Logical Link Control) — upper sublayer
- **MAC** (Media Access Control) — lower sublayer

**Layer 1 – Physical**
Raw bits transmitted over physical medium. Hubs, cables, repeaters.

> **Exam Tip:** Know which devices operate at which layers:
> - Hub = Layer 1, Switch = Layer 2, Router = Layer 3, Multilayer Switch = Layers 2+3

---

## 2. TCP/IP Model

The TCP/IP model is the practical model used on the internet. It maps to (and condenses) the OSI model.

```
┌──────────────────────────────────────────────────────────────┐
│  TCP/IP Layer      │  OSI Equivalent     │  Protocols        │
├──────────────────────────────────────────────────────────────┤
│  Application       │  7, 6, 5            │  HTTP, DNS, SMTP  │
├──────────────────────────────────────────────────────────────┤
│  Transport         │  4                  │  TCP, UDP         │
├──────────────────────────────────────────────────────────────┤
│  Internet          │  3                  │  IP, ICMP, ARP    │
├──────────────────────────────────────────────────────────────┤
│  Network Access    │  2, 1               │  Ethernet, 802.11 │
└──────────────────────────────────────────────────────────────┘
```

### Encapsulation and De-encapsulation

Data travels down the OSI stack on the sender, each layer **adding a header** (and sometimes trailer). On the receiver, it travels up — each layer **removing its header**.

```
SENDER                                    RECEIVER
───────                                   ────────
App Data                                  App Data
  ↓ +TCP/UDP header = Segment               ↑ strip TCP header
    ↓ +IP header = Packet                 ↑ strip IP header
      ↓ +Eth header+trailer = Frame     ↑ strip Eth header
        ↓ bits on wire ──────────────→ bits arrive
```

---

## 3. Network Topologies

### Physical Topologies

**Star (most common for LANs)**
```
         [PC1]
           |
[PC2]---[SWITCH]---[PC3]
           |
         [PC4]
```
All devices connect to a central switch. Single point of failure at the switch.

**Bus**
```
[PC1]---[PC2]---[PC3]---[PC4]
─────────────────────────────
         Shared medium
```
All share one cable. A break breaks the whole network. Legacy.

**Ring**
```
[PC1]──[PC2]
  |         |
[PC4]──[PC3]
```
Data travels in one direction. Token Ring (legacy). SONET rings still used in WAN.

**Mesh (Full)**
```
[R1]───[R2]
 │ ╲   ╱ │
 │  ╲ ╱  │
 │   ╳   │
 │  ╱ ╲  │
[R4]───[R3]
```
Every device connects to every other. Most redundant, most expensive. Common in WAN/ISP core networks.

**Partial Mesh** — Some redundancy without full mesh cost. Common in enterprise WAN.

**Hybrid** — Combination of topologies. Most real-world networks.

### Logical Topologies

- **Two-Tier (Collapsed Core):** Access + Distribution/Core combined. Used in smaller networks.
- **Three-Tier:** Access → Distribution → Core. Enterprise standard for large campuses.
- **Spine-Leaf:** Data center architecture. Every leaf connects to every spine. Predictable latency.

```
THREE-TIER CAMPUS DESIGN
─────────────────────────

         [Core Layer]
        /              \
[Dist SW1]          [Dist SW2]     ← Distribution Layer
  /    \              /    \
[Acc1][Acc2]      [Acc3][Acc4]    ← Access Layer
  |     |            |     |
 PCs   PCs          PCs   PCs
```

```
SPINE-LEAF DATA CENTER
──────────────────────
[Spine1]───[Spine2]
    │ ╲   ╱ │
    │  ╲ ╱  │
[Leaf1][Leaf2][Leaf3]
  |      |      |
Servers Servers Servers
```

> **Exam Tip:** CCNA expects you to identify two-tier vs three-tier and understand spine-leaf for data centers.

---

## 4. Physical Media and Cabling

### Copper Cabling — UTP (Unshielded Twisted Pair)

| Category | Max Speed | Max Distance | Use |
|----------|-----------|--------------|-----|
| Cat 5 | 100 Mbps | 100m | Legacy |
| Cat 5e | 1 Gbps | 100m | Common in older installs |
| Cat 6 | 1 Gbps (10G short) | 100m (55m for 10G) | Common |
| Cat 6a | 10 Gbps | 100m | Modern installs |
| Cat 8 | 25/40 Gbps | 30m | Data centers |

**RJ-45 Wiring Standards:**

```
T568A                    T568B
Pin 1: White/Green       Pin 1: White/Orange
Pin 2: Green             Pin 2: Orange
Pin 3: White/Orange      Pin 3: White/Green
Pin 4: Blue              Pin 4: Blue
Pin 5: White/Blue        Pin 5: White/Blue
Pin 6: Orange            Pin 6: Green
Pin 7: White/Brown       Pin 7: White/Brown
Pin 8: Brown             Pin 8: Brown
```

**Cable types:**
- **Straight-through** — Both ends same standard (T568B/T568B). Used: PC→Switch, Router→Switch
- **Crossover** — One end T568A, other T568B. Used: PC→PC, Switch→Switch (legacy)
- **Rollover/Console** — Cisco-specific. PC serial port to router/switch console port

> **Exam Tip:** Modern devices use **Auto-MDIX** — they automatically detect and adjust cable type. Crossover cables are largely obsolete, but you still need to know when they'd be needed.

### Fiber Optic

| Type | Core | Distance | Use |
|------|------|----------|-----|
| Single-mode (SMF) | 8-10 μm | Up to 100km | WAN, long campus runs |
| Multimode (MMF) | 50-62.5 μm | Up to 550m | Data center, short campus |

- **Single-mode:** Laser light source, long distances, more expensive
- **Multimode:** LED light source, shorter distances, cheaper
- **Connectors:** LC (most common), SC, ST, FC
- **Transceivers:** SFP (1G), SFP+ (10G), QSFP (40G/100G)

> **Exam Tip:** "Single-mode = Single long hallway for light." "Multimode = Multiple light paths (modal dispersion limits distance)."

### Common Interface Issues

| Symptom | Likely Cause |
|---------|-------------|
| Interface down/down | No cable, wrong cable type, other end down |
| Interface up/down | Layer 1 ok, Layer 2 issue (duplex mismatch, etc.) |
| CRC errors | Cable issue, duplex mismatch, EMI interference |
| Runts | Frames < 64 bytes (collision or duplex mismatch) |
| Giants | Frames > 1518 bytes (misconfigured MTU) |

---

## 5. Network Devices

### Hub (Layer 1)
- Repeats signal out all ports
- **Half-duplex** — one device transmits at a time
- Creates a **collision domain** — only one device can send at a time
- All ports in same **broadcast domain**
- Legacy — not used in modern networks

### Switch (Layer 2)
- Forwards frames based on **MAC address table**
- Each port = its own **collision domain** (no collisions)
- By default, all ports in same **broadcast domain** (one VLAN)
- **Full-duplex** per port
- Learns MAC addresses by reading source MAC from incoming frames

```
SWITCH MAC TABLE EXAMPLE
─────────────────────────
Port │ MAC Address      │ VLAN
─────┼──────────────────┼─────
Gi0/1│ AA:BB:CC:DD:EE:01│  1
Gi0/2│ AA:BB:CC:DD:EE:02│  1
Gi0/3│ AA:BB:CC:DD:EE:03│ 10
```

**Switch forwarding behavior:**
- **Known unicast** — forwards out specific port (from MAC table)
- **Unknown unicast** — floods out all ports except source
- **Broadcast** — floods out all ports except source
- **Multicast** — floods (unless IGMP snooping configured)

### Router (Layer 3)
- Forwards **packets** based on destination **IP address**
- Each interface = its own **broadcast domain** AND **collision domain**
- Connects different networks/subnets
- Decrements TTL by 1 for each hop
- Does not forward Layer 2 broadcasts

### Multilayer Switch (Layer 3 Switch)
- Switches at Layer 2 AND routes at Layer 3
- Has **SVIs (Switched Virtual Interfaces)** for routing between VLANs
- Hardware-based routing (faster than routers for L3 switching)

### Other Devices

| Device | Function |
|--------|----------|
| **Wireless AP** | Connects wireless devices to wired network |
| **WLC** (Wireless LAN Controller) | Centrally manages lightweight APs |
| **Firewall** | Filters traffic based on security policy |
| **NGFW** (Next-Gen Firewall) | Firewall + IPS + App awareness + URL filtering |
| **IDS/IPS** | Detects/prevents network intrusions |

---

## 6. IPv4 Addressing

### Address Format
IPv4 uses **32-bit** addresses written as four octets in dotted-decimal notation.

```
192.168.1.100
│    │   │  │
│    │   │  └── Host portion (in /24)
│    │   └───── Network portion
│    └───────── Network portion
└────────────── Network portion
```

Binary representation:
```
192      .168      .1        .100
11000000 .10101000 .00000001 .01100100
```

### IPv4 Address Classes (legacy — know for context)

| Class | First Octet | Default Mask | Private Range | Use |
|-------|-------------|--------------|---------------|-----|
| A | 1–126 | /8 (255.0.0.0) | 10.0.0.0/8 | Large networks |
| B | 128–191 | /16 (255.255.0.0) | 172.16.0.0/12 | Medium networks |
| C | 192–223 | /24 (255.255.255.0) | 192.168.0.0/16 | Small networks |
| D | 224–239 | N/A | N/A | Multicast |
| E | 240–255 | N/A | N/A | Reserved/Research |

**Special addresses:**
- `127.0.0.0/8` — Loopback (127.0.0.1 = localhost)
- `0.0.0.0` — This host on this network / default route
- `255.255.255.255` — Limited broadcast
- `169.254.0.0/16` — APIPA (Automatic Private IP — no DHCP response)

### Private IP Ranges (RFC 1918)
```
10.0.0.0    – 10.255.255.255   (10.0.0.0/8)     Class A private
172.16.0.0  – 172.31.255.255   (172.16.0.0/12)  Class B private
192.168.0.0 – 192.168.255.255  (192.168.0.0/16) Class C private
```
Private IPs are not routable on the internet. NAT is used to translate them.

---

## 7. Subnetting

Subnetting is **the most critical skill** for the CCNA exam. Practice until you can subnet in your head.

### The Subnet Mask

A subnet mask marks which bits are **network** (1s) and which are **host** (0s).

```
/24 mask:   11111111.11111111.11111111.00000000  = 255.255.255.0
/25 mask:   11111111.11111111.11111111.10000000  = 255.255.255.128
/26 mask:   11111111.11111111.11111111.11000000  = 255.255.255.192
/27 mask:   11111111.11111111.11111111.11100000  = 255.255.255.224
/28 mask:   11111111.11111111.11111111.11110000  = 255.255.255.240
/29 mask:   11111111.11111111.11111111.11111000  = 255.255.255.248
/30 mask:   11111111.11111111.11111111.11111100  = 255.255.255.252
```

### Key Formulas
- **Number of subnets** = 2^(borrowed bits)
- **Hosts per subnet** = 2^(host bits) − 2 (subtract network + broadcast)
- **Block size / Subnet increment** = 256 − subnet mask octet

### CIDR Quick Reference Table

| CIDR | Mask | Hosts | Block Size | Subnets of /24 |
|------|------|-------|------------|----------------|
| /24 | 255.255.255.0 | 254 | 256 | 1 |
| /25 | 255.255.255.128 | 126 | 128 | 2 |
| /26 | 255.255.255.192 | 62 | 64 | 4 |
| /27 | 255.255.255.224 | 30 | 32 | 8 |
| /28 | 255.255.255.240 | 14 | 16 | 16 |
| /29 | 255.255.255.248 | 6 | 8 | 32 |
| /30 | 255.255.255.252 | 2 | 4 | 64 |
| /31 | 255.255.255.254 | 0* | 2 | 128 |
| /32 | 255.255.255.255 | 1* | 1 | — |

**/31** — Used for point-to-point links (RFC 3021). No broadcast, 2 usable addresses.
**/32** — Host route (specific single IP).

### Subnetting Walkthrough

**Question:** Subnet 192.168.10.0/24 into /27 subnets. What are the subnets?

**Step 1:** Find block size → 256 − 224 = **32**

**Step 2:** List subnets (increment by 32):

```
Subnet 1:  192.168.10.0    Network:    192.168.10.0
           Range:          192.168.10.1 – 192.168.10.30
           Broadcast:      192.168.10.31

Subnet 2:  192.168.10.32   Network:    192.168.10.32
           Range:          192.168.10.33 – 192.168.10.62
           Broadcast:      192.168.10.63

Subnet 3:  192.168.10.64   Network:    192.168.10.64
           Range:          192.168.10.65 – 192.168.10.94
           Broadcast:      192.168.10.95
           ...continues...

Subnet 8:  192.168.10.224  Network:    192.168.10.224
           Range:          192.168.10.225 – 192.168.10.254
           Broadcast:      192.168.10.255
```

**Question:** What subnet does 172.16.45.200/20 belong to?

**Step 1:** /20 means 20 network bits. The interesting octet is the 3rd.
Mask = 255.255.240.0 → Block size in 3rd octet = 256 − 240 = **16**

**Step 2:** Divide the 3rd octet (45) by 16 → 45 / 16 = 2 remainder 13
Network address: 172.16.**32**.0/20

```
Network:   172.16.32.0
First host: 172.16.32.1
Last host:  172.16.47.254
Broadcast: 172.16.47.255   (32 + 16 - 1 = 47)
```

> **Exam Tip:** For any subnet question, the steps are always:
> 1. Find block size (256 − mask octet)
> 2. Find which subnet block the address falls in
> 3. Network = start of block, Broadcast = next block − 1

### Subnet Practice Problems

1. How many hosts can 10.0.0.0/21 support? *(2^11 − 2 = **2046**)*
2. You need 50 hosts per subnet. What's the smallest subnet? *(/26 = 62 hosts)*
3. You need 500 subnets from 10.0.0.0/8. What prefix? *(2^9=512 ≥ 500, so /8+9= **/17**)*
4. What's the broadcast of 192.168.100.65/26? *(Block=64, subnet starts at 64, broadcast= **192.168.100.127**)*

---

## 8. VLSM — Variable Length Subnet Masking

VLSM allows subnets of different sizes within the same major network. Essential for efficient IP address use.

**Scenario:** You have 192.168.1.0/24. Assign subnets for:
- Network A: 100 hosts needed
- Network B: 50 hosts needed
- Network C: 25 hosts needed
- Network D: 10 hosts needed
- Link 1 (point-to-point): 2 hosts
- Link 2 (point-to-point): 2 hosts

**Solution (always start with largest requirement first):**

```
Network A (100 hosts) → /25 (126 usable)
  Subnet: 192.168.1.0/25
  Range:  192.168.1.1 – 192.168.1.126
  Bcast:  192.168.1.127

Network B (50 hosts) → /26 (62 usable)
  Subnet: 192.168.1.128/26
  Range:  192.168.1.129 – 192.168.1.190
  Bcast:  192.168.1.191

Network C (25 hosts) → /27 (30 usable)
  Subnet: 192.168.1.192/27
  Range:  192.168.1.193 – 192.168.1.222
  Bcast:  192.168.1.223

Network D (10 hosts) → /28 (14 usable)
  Subnet: 192.168.1.224/28
  Range:  192.168.1.225 – 192.168.1.238
  Bcast:  192.168.1.239

Link 1 (2 hosts) → /30
  Subnet: 192.168.1.240/30
  Range:  192.168.1.241 – 192.168.1.242
  Bcast:  192.168.1.243

Link 2 (2 hosts) → /30
  Subnet: 192.168.1.244/30
  Range:  192.168.1.245 – 192.168.1.246
  Bcast:  192.168.1.247
```

---

## 9. IPv6 Addressing

### Why IPv6?
IPv4 has ~4.3 billion addresses (2^32). IPv6 has 340 undecillion (2^128).

### Format
128-bit address, written as 8 groups of 4 hex digits separated by colons.

```
Full:       2001:0DB8:0000:0001:0000:0000:0000:0001
Compressed: 2001:DB8:0:1::1
```

**Compression rules:**
1. Remove leading zeros within each group: `0001` → `1`
2. Replace one or more consecutive all-zero groups with `::` (only once per address)

```
Full:        FE80:0000:0000:0000:02AA:00FF:FE28:9C5A
Step 1:      FE80:0:0:0:2AA:FF:FE28:9C5A
Step 2:      FE80::2AA:FF:FE28:9C5A
```

### IPv6 Address Types

| Type | Prefix | Description |
|------|--------|-------------|
| **Global Unicast** | 2000::/3 | Public, routable (like public IPv4) |
| **Link-Local** | FE80::/10 | Auto-configured, not routable |
| **Loopback** | ::1/128 | Equivalent to 127.0.0.1 |
| **Unspecified** | ::/128 | Like 0.0.0.0, means "any" |
| **Unique Local** | FC00::/7 | Private (like RFC 1918), not routable |
| **Multicast** | FF00::/8 | One-to-many |
| **Anycast** | From unicast space | Nearest-device routing |

**Common Multicast Addresses:**

| Address | Scope |
|---------|-------|
| `FF02::1` | All nodes on link |
| `FF02::2` | All routers on link |
| `FF02::5` | OSPFv3 all routers |
| `FF02::6` | OSPFv3 DR/BDR |
| `FF02::A` | EIGRP routers |

**Solicited-Node Multicast:** `FF02::1:FF` + last 24 bits of unicast address. Used for Neighbor Discovery (replaces ARP).

### EUI-64 Interface ID Generation

When using SLAAC (Stateless Address Autoconfiguration), the host generates the 64-bit interface ID from its 48-bit MAC:

```
MAC:    AA:BB:CC:DD:EE:FF

Step 1: Split in half and insert FFFE in middle
        AA:BB:CC:FF:FE:DD:EE:FF

Step 2: Flip the 7th bit (Universal/Local bit) of first byte
        AA = 10101010 → flip 7th bit → 10101000 = A8

Result: A8:BB:CC:FF:FE:DD:EE:FF

IPv6 Interface ID: A8BB:CCFF:FEDD:EEFF
```

### IPv6 Configuration on Cisco Router

```
! Enable IPv6 routing
Router(config)# ipv6 unicast-routing

! Assign global unicast address
Router(config-if)# ipv6 address 2001:DB8:1:1::1/64

! Assign link-local manually
Router(config-if)# ipv6 address FE80::1 link-local

! Use EUI-64 for interface ID
Router(config-if)# ipv6 address 2001:DB8:1:1::/64 eui-64

! Enable on interface
Router(config-if)# no shutdown

! Verify
Router# show ipv6 interface brief
Router# show ipv6 route
```

### No ARP in IPv6 — NDP Instead

**Neighbor Discovery Protocol (NDP)** replaces ARP and provides:
- **NS (Neighbor Solicitation)** — like ARP request
- **NA (Neighbor Advertisement)** — like ARP reply
- **RS (Router Solicitation)** — host asks for router info
- **RA (Router Advertisement)** — router sends prefix info for SLAAC

---

## 10. TCP vs UDP

### TCP (Transmission Control Protocol)

**Connection-oriented** — requires a 3-way handshake before data transfer.

```
CLIENT          SERVER
  │───SYN─────────→│  (I want to connect, seq=100)
  │←──SYN-ACK──────│  (OK, seq=200, ack=101)
  │───ACK──────────→│  (Got it, ack=201)
  │      DATA       │
  │←───────────────→│
  │───FIN──────────→│  (I'm done)
  │←──FIN-ACK───────│
  │───ACK──────────→│
```

**TCP Features:**
- Sequencing — data arrives in order
- Acknowledgment — receiver confirms receipt
- Retransmission — lost data is resent
- Flow control — receiver controls sender rate (Window size)
- Error checking — checksum

### UDP (User Datagram Protocol)

**Connectionless** — just sends data, no handshake.

**UDP Characteristics:**
- Low overhead / Low latency
- No guarantee of delivery, order, or error recovery
- Application handles reliability if needed
- Good for: DNS, DHCP, VoIP, video streaming, gaming, TFTP

### Comparison

| Feature | TCP | UDP |
|---------|-----|-----|
| Connection | Yes (3-way handshake) | No |
| Reliable delivery | Yes | No |
| Ordering | Yes | No |
| Error recovery | Yes | No |
| Speed | Slower (overhead) | Faster |
| Use cases | HTTP, FTP, SSH, email | DNS, DHCP, VoIP, video |
| Header size | 20+ bytes | 8 bytes |

---

## 11. Common Ports and Protocols

| Port | Protocol | Transport | Description |
|------|----------|-----------|-------------|
| 20 | FTP Data | TCP | File transfer data |
| 21 | FTP Control | TCP | File transfer control |
| 22 | SSH | TCP | Secure shell |
| 23 | Telnet | TCP | Unsecure remote access |
| 25 | SMTP | TCP | Send email |
| 53 | DNS | TCP/UDP | Domain name resolution |
| 67 | DHCP Server | UDP | DHCP offers |
| 68 | DHCP Client | UDP | DHCP requests |
| 69 | TFTP | UDP | Trivial file transfer |
| 80 | HTTP | TCP | Web traffic |
| 110 | POP3 | TCP | Retrieve email |
| 123 | NTP | UDP | Time sync |
| 143 | IMAP | TCP | Email retrieval |
| 161 | SNMP | UDP | Network management |
| 162 | SNMP Trap | UDP | Unsolicited SNMP alerts |
| 443 | HTTPS | TCP | Secure web |
| 514 | Syslog | UDP | Log messages |
| 1812 | RADIUS Auth | UDP | AAA authentication |
| 1813 | RADIUS Acct | UDP | AAA accounting |

> **Exam Tip:** Know these ports cold. DNS uses both TCP and UDP — UDP for queries under 512 bytes, TCP for zone transfers and large responses.

---

## 12. Switching Fundamentals

### How a Switch Works

1. **Receive frame** on a port
2. **Read source MAC** — add to MAC address table with port number
3. **Look up destination MAC** in table
4. If found (**known unicast**) → forward out specific port
5. If not found (**unknown unicast**) → **flood** out all ports except incoming
6. If destination = broadcast → **flood** out all ports except incoming

### MAC Address Table (CAM Table)

```
Switch# show mac address-table
          Mac Address Table
───────────────────────────────────────────
Vlan    Mac Address       Type        Ports
────    ───────────       ────        ─────
   1    aabb.cc00.0100    DYNAMIC     Gi0/1
   1    aabb.cc00.0200    DYNAMIC     Gi0/2
  10    aabb.cc00.0300    DYNAMIC     Gi0/3
```

Entries age out (default 300 seconds = 5 minutes).

### Duplex

- **Full-duplex:** Simultaneous send and receive — no collisions. Modern standard.
- **Half-duplex:** One direction at a time — uses CSMA/CD to detect/recover from collisions. Legacy (hubs, old devices).

**Duplex mismatch** — One end full, other half. Results in CRC errors, collisions, poor performance.

```
! Configure interface duplex and speed
Switch(config-if)# duplex full
Switch(config-if)# speed 1000
Switch(config-if)# no shutdown

! Or let it auto-negotiate (recommended for most cases)
Switch(config-if)# duplex auto
Switch(config-if)# speed auto

! Verify
Switch# show interfaces GigabitEthernet0/1
  GigabitEthernet0/1 is up, line protocol is up
  Hardware is Gigabit Ethernet, address is aabb.cc00.0100
  MTU 1500 bytes, BW 1000000 Kbit/s, DLY 10 usec
  Full-duplex, 1Gb/s
```

### Broadcast and Collision Domains

```
         [HUB]              [SWITCH]
        /  |  \            /   |   \
    [PC1][PC2][PC3]    [PC1][PC2][PC3]

HUB:
  - 1 collision domain (all share medium)
  - 1 broadcast domain

SWITCH:
  - 3 collision domains (1 per port)
  - 1 broadcast domain (per VLAN)

ROUTER:
  Each interface = 1 collision domain + 1 broadcast domain
```

> **Exam Tip:** A router breaks up broadcast domains. A switch breaks up collision domains. Each router interface is a separate broadcast domain and collision domain.

### Layer 2 vs Layer 3 Forwarding Decision

**Layer 2 (Switch):**
1. Look at destination **MAC address**
2. Forward/flood based on MAC table

**Layer 3 (Router):**
1. Strip Layer 2 header
2. Look at destination **IP address**
3. Check routing table → find next hop
4. Build new Layer 2 header with next-hop MAC
5. Forward

---

## Chapter 1 Summary

| Topic | Key Points |
|-------|-----------|
| OSI Model | 7 layers — know PDUs and devices per layer |
| TCP/IP | 4 layers — practical model for the internet |
| Subnetting | Know block sizes and formulas cold |
| IPv6 | 128-bit, know address types and compression rules |
| TCP vs UDP | TCP = reliable/ordered, UDP = fast/simple |
| Switching | MAC table, flooding, broadcast/collision domains |

---

*[← Back to README](../README.md) | [Chapter 2: Network Access →](02-network-access.md)*
# Chapter 2: Network Access

> **Exam Weight: 20%**

---

## Table of Contents
1. [VLANs](#1-vlans)
2. [VLAN Trunking (802.1Q)](#2-vlan-trunking-8021q)
3. [Inter-VLAN Routing](#3-inter-vlan-routing)
4. [VTP (VLAN Trunking Protocol)](#4-vtp-vlan-trunking-protocol)
5. [Layer 2 Discovery Protocols (CDP & LLDP)](#5-layer-2-discovery-protocols-cdp--lldp)
6. [Spanning Tree Protocol (STP)](#6-spanning-tree-protocol-stp)
7. [Rapid PVST+](#7-rapid-pvst)
8. [EtherChannel](#8-etherchannel)
9. [Wireless Fundamentals](#9-wireless-fundamentals)
10. [Wireless Security](#10-wireless-security)

---

## 1. VLANs

### What is a VLAN?

A **Virtual LAN (VLAN)** logically segments a physical network into separate broadcast domains — as if they were on separate switches. VLANs provide:
- **Security** — isolate traffic between departments
- **Performance** — reduce broadcast traffic
- **Flexibility** — group users logically regardless of physical location

```
WITHOUT VLANs (one big broadcast domain):
─────────────────────────────────────────
[PC-Sales1][PC-Sales2][PC-HR1][PC-HR2]
         └──────────[SWITCH]──────────┘
         All in same broadcast domain

WITH VLANs (separate broadcast domains):
─────────────────────────────────────────
[PC-Sales1][PC-Sales2]   [PC-HR1][PC-HR2]
      └─────VLAN10──┘         └──VLAN20──┘
              └────────[SWITCH]────────┘
         Traffic isolated by VLAN
```

### VLAN Types

| Type | Description |
|------|-------------|
| **Data VLAN** | Carries regular user traffic |
| **Default VLAN** | VLAN 1 — all ports start here |
| **Native VLAN** | Untagged traffic on a trunk (default VLAN 1) |
| **Management VLAN** | SVI used for switch management (SSH, Telnet) |
| **Voice VLAN** | Dedicated VLAN for VoIP phones |

**VLAN ID Ranges:**
- `1` — Default VLAN (cannot be deleted)
- `2–1001` — Normal range (stored in vlan.dat)
- `1002–1005` — Reserved for legacy (Token Ring, FDDI)
- `1006–4094` — Extended range (requires VTP transparent or off mode)

### VLAN Configuration

```
! Create VLANs
Switch(config)# vlan 10
Switch(config-vlan)# name Sales
Switch(config-vlan)# exit

Switch(config)# vlan 20
Switch(config-vlan)# name HR
Switch(config-vlan)# exit

! Assign ports to VLANs (access ports)
Switch(config)# interface GigabitEthernet0/1
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 10
Switch(config-if)# exit

Switch(config)# interface GigabitEthernet0/2
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 20
Switch(config-if)# exit

! Configure a Voice VLAN on an access port
Switch(config)# interface GigabitEthernet0/3
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 10
Switch(config-if)# switchport voice vlan 99
Switch(config-if)# exit

! Verify VLANs
Switch# show vlan brief

VLAN Name                             Status    Ports
──── ────────────────────────────── ─────────  ─────────────────
1    default                        active    Gi0/4, Gi0/5
10   Sales                          active    Gi0/1
20   HR                             active    Gi0/2

! Show VLAN details
Switch# show vlan id 10
Switch# show interfaces GigabitEthernet0/1 switchport
```

---

## 2. VLAN Trunking (802.1Q)

A **trunk** carries traffic for **multiple VLANs** between switches (or between a switch and a router). It uses **802.1Q tagging** to identify which VLAN each frame belongs to.

```
ACCESS PORT vs TRUNK PORT
──────────────────────────────────────────────────────

ACCESS PORT:           TRUNK PORT:
One VLAN only          Multiple VLANs
No tag added           802.1Q tag added/stripped

[PC]──access──[SW]═════trunk═════[SW]──access──[PC]
       VLAN10          VLAN10,20,30       VLAN20
```

### 802.1Q Frame

The switch inserts a 4-byte tag into the Ethernet frame between the Source MAC and EtherType fields:

```
Normal Ethernet Frame:
│ Dst MAC │ Src MAC │ EtherType │ Data │ FCS │

802.1Q Tagged Frame:
│ Dst MAC │ Src MAC │ 802.1Q Tag │ EtherType │ Data │ FCS │
                     │           │
                     │ TPID(2B)  │  PCP │ DEI │ VLAN ID(12bit) │
                     │ 0x8100    │       802.1Q Header (4 bytes)  │
```

**VLAN ID is 12 bits** → 2^12 = 4096 possible VLANs (0 and 4095 reserved → 4094 usable)

### Native VLAN

The **native VLAN** is the one VLAN whose frames are sent **untagged** on a trunk. Default is VLAN 1.

> **Security Tip:** Change the native VLAN away from VLAN 1 and ensure it matches on both ends to prevent VLAN hopping attacks.

### Trunk Configuration

```
! Configure a trunk port
Switch(config)# interface GigabitEthernet0/24
Switch(config-if)# switchport trunk encapsulation dot1q    ! needed on some older switches
Switch(config-if)# switchport mode trunk
Switch(config-if)# switchport trunk native vlan 999        ! change native VLAN (security)
Switch(config-if)# switchport trunk allowed vlan 10,20,30  ! restrict allowed VLANs

! Allow additional VLANs
Switch(config-if)# switchport trunk allowed vlan add 40

! Verify trunk
Switch# show interfaces trunk

Port        Mode         Encapsulation  Status        Native vlan
Gi0/24      on           802.1q         trunking      999

Port        Vlans allowed on trunk
Gi0/24      10,20,30

Port        Vlans allowed and active in management domain
Gi0/24      10,20,30

Port        Vlans in spanning tree forwarding state and not pruned
Gi0/24      10,20,30
```

### DTP (Dynamic Trunking Protocol)

Cisco proprietary. Automatically negotiates trunk status between Cisco switches.

| Mode | Behavior |
|------|----------|
| **access** | Always access port, never trunks |
| **trunk** | Always trunk port |
| **dynamic auto** | Will trunk if neighbor initiates (default on many switches) |
| **dynamic desirable** | Actively tries to form trunk |
| **nonegotiate** | Disables DTP (use with `switchport mode trunk`) |

```
! Disable DTP (best practice for security)
Switch(config-if)# switchport mode trunk
Switch(config-if)# switchport nonegotiate

! For access ports
Switch(config-if)# switchport mode access
Switch(config-if)# switchport nonegotiate
```

> **Exam Tip:** DTP negotiation table:

| | trunk | dynamic desirable | dynamic auto | access |
|--|-------|-------------------|--------------|--------|
| **trunk** | trunk | trunk | trunk | access |
| **dynamic desirable** | trunk | trunk | trunk | access |
| **dynamic auto** | trunk | trunk | access | access |
| **access** | access | access | access | access |

---

## 3. Inter-VLAN Routing

Devices in different VLANs cannot communicate without a Layer 3 device. Three options:

### Option 1 — Legacy (One physical link per VLAN)

```
[SWITCH]──────────────────[ROUTER]
  VLAN10 ──Gi0/0──────── Gi0/0 (192.168.10.1/24)
  VLAN20 ──Gi0/1──────── Gi0/1 (192.168.20.1/24)
```
Wastes router interfaces. Only practical for very few VLANs.

### Option 2 — Router-on-a-Stick (ROAS)

One physical trunk link. Router uses **subinterfaces** — one per VLAN.

```
[PC-Sales]──[SWITCH]══trunk══[ROUTER]
             VLAN10,20        Gi0/0
                             / Gi0/0.10
                            /  Gi0/0.20
```

```
! Router-on-a-Stick Configuration
Router(config)# interface GigabitEthernet0/0
Router(config-if)# no shutdown
Router(config-if)# exit

! Create subinterface for VLAN 10
Router(config)# interface GigabitEthernet0/0.10
Router(config-subif)# encapsulation dot1Q 10
Router(config-subif)# ip address 192.168.10.1 255.255.255.0
Router(config-subif)# exit

! Create subinterface for VLAN 20
Router(config)# interface GigabitEthernet0/0.20
Router(config-subif)# encapsulation dot1Q 20
Router(config-subif)# ip address 192.168.20.1 255.255.255.0
Router(config-subif)# exit

! On the switch — configure the port toward router as trunk
Switch(config)# interface GigabitEthernet0/24
Switch(config-if)# switchport mode trunk
Switch(config-if)# switchport trunk encapsulation dot1q

! Verify
Router# show ip interface brief
Router# show interfaces GigabitEthernet0/0.10
```

### Option 3 — Layer 3 Switch with SVIs (Best for Modern Networks)

A **Switched Virtual Interface (SVI)** is a virtual interface on a switch, one per VLAN. The L3 switch routes between VLANs internally.

```
[PC-Sales]──[L3 SWITCH]──[PC-HR]
             VLAN10 SVI: 192.168.10.1
             VLAN20 SVI: 192.168.20.1
             ip routing enabled
```

```
! Layer 3 Switch Inter-VLAN Routing
Switch(config)# ip routing                     ! enable L3 routing

! Create SVIs
Switch(config)# interface vlan 10
Switch(config-if)# ip address 192.168.10.1 255.255.255.0
Switch(config-if)# no shutdown
Switch(config-if)# exit

Switch(config)# interface vlan 20
Switch(config-if)# ip address 192.168.20.1 255.255.255.0
Switch(config-if)# no shutdown
Switch(config-if)# exit

! Configure access ports as before
Switch(config)# interface GigabitEthernet0/1
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 10

! Verify routing
Switch# show ip route
Switch# show interfaces vlan 10
```

> **Exam Tip:** SVIs are the preferred method for inter-VLAN routing in modern campus networks. ROAS is common in smaller environments or on a CCNA lab.

---

## 4. VTP (VLAN Trunking Protocol)

Cisco proprietary. Synchronizes VLAN databases across switches. **Be careful — VTP can wipe VLANs!**

### VTP Modes

| Mode | Creates VLANs | Forwards Updates | Stores VLAN info |
|------|--------------|------------------|-----------------|
| **Server** | Yes | Yes | Yes |
| **Client** | No | Yes | No (in memory) |
| **Transparent** | Yes (local only) | Yes (passes through) | Yes (local) |
| **Off** | Yes (local only) | No | Yes (local) |

```
! VTP Configuration
Switch(config)# vtp mode server
Switch(config)# vtp domain CCNA-LAB
Switch(config)# vtp password cisco123
Switch(config)# vtp version 2

! Verify
Switch# show vtp status

VTP Version capable             : 1 to 3
VTP version running             : 2
VTP Domain Name                 : CCNA-LAB
VTP Pruning Mode                : Disabled
VTP Traps Generation            : Disabled
Device ID                       : aabb.cc00.0100
Configuration last modified by 0.0.0.0 at 3-1-93 00:00:00
Local updater ID is 192.168.1.1

Feature VLAN:
──────────────────────────────────
VTP Operating Mode                : Server
Maximum VLANs supported locally   : 1005
Number of existing VLANs          : 8
Configuration Revision            : 5
MD5 digest                        : 0x12 0x34 ...
```

> **Exam Tip:** VTP revision number danger — if a switch with a higher revision number joins a domain, it can **overwrite** existing VLAN databases on servers and clients. Best practice is to use VTP transparent or off mode and manage VLANs manually.

---

## 5. Layer 2 Discovery Protocols (CDP & LLDP)

### CDP (Cisco Discovery Protocol)

Cisco proprietary. Layer 2. Enabled by default on Cisco devices. Discovers directly connected Cisco neighbors.

```
! Show CDP neighbors (summary)
Switch# show cdp neighbors

Capability Codes: R - Router, T - Trans Bridge, B - Source Route Bridge
                  S - Switch, H - Host, I - IGMP, r - Repeater, P - Phone

Device ID        Local Intrfce     Holdtme    Capability  Platform  Port ID
Router1          Gi0/24            165           R S      C1941     Gi0/0
Switch2          Gi0/23            160             S      WS-C2960  Gi0/1

! Show detailed CDP neighbor info
Switch# show cdp neighbors detail

Device ID: Router1
  IP address: 192.168.1.1
  Platform: Cisco C1941, Capabilities: Router Switch
  Interface: GigabitEthernet0/24, Port ID (outgoing port): GigabitEthernet0/0
  Holdtime: 165 sec
  Version: Cisco IOS Software, Version 15.2(4)M...
  VTP Management Domain: 'CCNA-LAB'
  Native VLAN: 1

! Disable CDP globally (security best practice on edge ports)
Switch(config)# no cdp run

! Disable CDP per interface
Switch(config-if)# no cdp enable
```

### LLDP (Link Layer Discovery Protocol)

IEEE standard (802.1AB). Vendor-neutral. Works between Cisco and non-Cisco devices.

```
! Enable LLDP globally (disabled by default on Cisco)
Switch(config)# lldp run

! Enable transmit and receive per interface
Switch(config-if)# lldp transmit
Switch(config-if)# lldp receive

! Verify
Switch# show lldp neighbors

Capability codes:
    (R) Router, (B) Bridge, (T) Telephone, (C) DOCSIS Cable Device
    (W) WLAN Access Point, (P) Repeater, (S) Station, (O) Other

Device ID           Local Intf     Hold-time  Capability   Port ID
Switch2             Gi0/23         120         B            Gi0/1

Switch# show lldp neighbors detail
```

> **Exam Tip:** CDP is Cisco-only, enabled by default. LLDP is open standard, disabled by default on Cisco. Disable CDP/LLDP on ports facing untrusted networks.

---

## 6. Spanning Tree Protocol (STP)

### Why STP?

Redundant links = loops. Loops cause **broadcast storms** (exponential replication of broadcast frames) and **MAC table instability**.

```
WITHOUT STP (LOOP):          WITH STP (LOOP BLOCKED):
─────────────────────        ────────────────────────
[SW1]═══[SW2]═══[SW3]        [SW1]═══[SW2]════[SW3]
  ╚═══════════════╝             ╚════ ✗ blocked ╝
  Broadcast loops forever       Port blocked by STP
```

### STP Election Process

**Step 1: Elect Root Bridge**
- Bridge with lowest **Bridge ID (BID)** wins
- BID = Priority (16 bits) + MAC address (48 bits)
- Default priority = **32768** (+ VLAN ID in PVST+)
- Lower priority = more likely to become root

**Step 2: Elect Root Ports**
- Each non-root bridge selects one port toward the root
- Chosen by lowest **Root Path Cost**

**Step 3: Elect Designated Ports**
- Each network segment gets one designated port
- All root bridge ports = designated
- Non-root, non-root-port = **blocked (alternate port)**

### STP Port Cost (Original 802.1D)

| Link Speed | Cost |
|-----------|------|
| 10 Mbps | 100 |
| 100 Mbps | 19 |
| 1 Gbps | 4 |
| 10 Gbps | 2 |

### STP Port States

```
STP PORT STATE MACHINE:

DISABLED → BLOCKING → LISTENING → LEARNING → FORWARDING
               ↑___________________________|
                    (if loop detected)

State       | Receives BPDUs | Sends BPDUs | Learn MACs | Forward Frames
────────────────────────────────────────────────────────────────────────
BLOCKING    |    Yes         |    No       |    No      |    No
LISTENING   |    Yes         |    Yes      |    No      |    No  (15 sec)
LEARNING    |    Yes         |    Yes      |    Yes     |    No  (15 sec)
FORWARDING  |    Yes         |    Yes      |    Yes     |    Yes
DISABLED    |    No          |    No       |    No      |    No
```

**Convergence time:** 802.1D STP takes **~50 seconds** to converge:
- 20 seconds Max Age (detecting topology change)
- 15 seconds Listening
- 15 seconds Learning

### STP Configuration and Tuning

```
! View STP status
Switch# show spanning-tree

VLAN0001
  Spanning tree enabled protocol ieee
  Root ID    Priority    32769
             Address     aabb.cc00.0100
             This bridge is the root
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32769  (priority 32768 sys-id-ext 1)
             Address     aabb.cc00.0100
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time  300 sec

Interface           Role Sts Cost      Prio.Nbr Type
─────────────────── ──── ─── ─────── ──────── ───────────
Gi0/1               Desg FWD 4         128.1   P2p
Gi0/2               Desg FWD 4         128.2   P2p
Gi0/24              Root FWD 4         128.24  P2p

! Influence Root Bridge Election (lower priority wins)
Switch(config)# spanning-tree vlan 10 priority 4096
! OR use the macro
Switch(config)# spanning-tree vlan 10 root primary       ! sets to 24576 or lower
Switch(config)# spanning-tree vlan 20 root secondary     ! sets to 28672

! Configure port cost manually
Switch(config-if)# spanning-tree vlan 10 cost 10

! Configure port priority (lower = more preferred)
Switch(config-if)# spanning-tree vlan 10 port-priority 64

! PortFast — skip Listening/Learning for end-device ports
Switch(config-if)# spanning-tree portfast

! Enable portfast globally for all access ports
Switch(config)# spanning-tree portfast default

! BPDU Guard — shut port if BPDU received (used with PortFast)
Switch(config-if)# spanning-tree bpduguard enable
! OR globally for all portfast ports
Switch(config)# spanning-tree portfast bpduguard default

! BPDU Filter — don't send/receive BPDUs on port
Switch(config-if)# spanning-tree bpdufilter enable
```

> **Exam Tip:** Enable `spanning-tree portfast` on access ports connecting to end devices (PCs, phones, servers). Always pair with `bpduguard` to shut the port if a switch is accidentally plugged in.

### Root Guard and Loop Guard

```
! Root Guard — prevents a port from becoming a root port
! Use on ports that should never lead to the root
Switch(config-if)# spanning-tree guard root

! Loop Guard — prevents forwarding if BPDUs stop being received
! Protects against unidirectional link failures
Switch(config-if)# spanning-tree guard loop
```

### PVST+ (Per-VLAN Spanning Tree Plus)

Cisco default STP mode. Runs a separate STP instance per VLAN. Allows load balancing:

```
! VLAN 10 root on Switch 1, VLAN 20 root on Switch 2 = load balance
Switch1(config)# spanning-tree vlan 10 root primary
Switch1(config)# spanning-tree vlan 20 root secondary

Switch2(config)# spanning-tree vlan 20 root primary
Switch2(config)# spanning-tree vlan 10 root secondary
```

---

## 7. Rapid PVST+

**IEEE 802.1w** (Rapid STP). Converges in **~1-2 seconds** instead of 50 seconds.

### Key Improvements over 802.1D

1. **Only 3 port states** (vs 5)
2. **New port roles** — Alternate and Backup
3. **Proposal/Agreement handshake** — rapid transition to forwarding
4. **Edge ports** (like PortFast) built-in

### RSTP Port States

| RSTP State | 802.1D Equivalent |
|------------|-------------------|
| Discarding | Disabled + Blocking + Listening |
| Learning | Learning |
| Forwarding | Forwarding |

### RSTP Port Roles

| Role | Description |
|------|-------------|
| **Root** | Best port toward root bridge |
| **Designated** | Best port on each segment |
| **Alternate** | Backup path to root (discarding) |
| **Backup** | Redundant designated port (discarding) |
| **Edge** | Connected to end device — goes to forwarding immediately |

```
! Enable Rapid PVST+ (Cisco default on modern switches)
Switch(config)# spanning-tree mode rapid-pvst

! Verify
Switch# show spanning-tree

VLAN0010
  Spanning tree enabled protocol rstp    ← confirms RSTP
  Root ID    Priority    24586
             ...

Interface           Role Sts Cost      Prio.Nbr Type
─────────────────── ──── ─── ─────── ──────── ───────────
Gi0/1               Desg FWD 4         128.1   P2p
Gi0/2               Altn BLK 4         128.2   P2p    ← Alternate port
```

> **Exam Tip:** Know the difference: PVST+ uses 802.1D (50 sec convergence), Rapid PVST+ uses 802.1w (~1-2 sec convergence). Modern Cisco switches default to **Rapid PVST+**.

---

## 8. EtherChannel

**EtherChannel** bundles 2–8 physical links into one logical link. Provides:
- **Increased bandwidth** (load balancing across physical links)
- **Redundancy** (if one link fails, others keep working)
- **STP sees it as one link** (no blocked ports)

```
WITHOUT EtherChannel:          WITH EtherChannel:
──────────────────────         ──────────────────────
[SW1]──────────────[SW2]       [SW1]══Po1═════[SW2]
[SW1]─── BLOCKED ─[SW2]        Link1 (active)
[SW1]─── BLOCKED ─[SW2]        Link2 (active)
STP blocks redundant links      Link3 (active)
                                ALL links forward!
```

### EtherChannel Negotiation Protocols

| Protocol | Type | Description |
|----------|------|-------------|
| **LACP** (802.3ad) | Open standard | IEEE standard, works between Cisco and non-Cisco |
| **PAgP** | Cisco proprietary | Only between Cisco devices |
| **Static (On)** | None | No negotiation — both ends manually set to on |

### LACP Modes

| Mode | Behavior |
|------|----------|
| **active** | Actively sends LACP packets, forms channel if other end is active or passive |
| **passive** | Only forms channel if other end is active |

**LACP will form if:** active-active OR active-passive
**LACP will NOT form if:** passive-passive

### PAgP Modes

| Mode | Behavior |
|------|----------|
| **desirable** | Actively sends PAgP packets |
| **auto** | Only forms if other end initiates |

**PAgP will form if:** desirable-desirable OR desirable-auto
**PAgP will NOT form if:** auto-auto

### EtherChannel Configuration

```
! LACP EtherChannel (recommended — open standard)
Switch(config)# interface range GigabitEthernet0/1-3
Switch(config-if-range)# channel-group 1 mode active
Switch(config-if-range)# exit

! Configure the port-channel interface
Switch(config)# interface port-channel 1
Switch(config-if)# switchport mode trunk
Switch(config-if)# switchport trunk encapsulation dot1q
Switch(config-if)# switchport trunk allowed vlan 10,20,30

! PAgP EtherChannel
Switch(config)# interface range GigabitEthernet0/1-3
Switch(config-if-range)# channel-group 1 mode desirable
Switch(config-if-range)# exit

! Static EtherChannel (no negotiation)
Switch(config)# interface range GigabitEthernet0/1-3
Switch(config-if-range)# channel-group 1 mode on
Switch(config-if-range)# exit

! Verify EtherChannel
Switch# show etherchannel summary

Flags:  D - down        P - bundled in port-channel
        I - stand-alone s - suspended
        H - Hot-standby (LACP only)
        R - Layer3      S - Layer2
        U - in use      f - failed to allocate aggregator

        M - not in use, minimum links not met
        u - unsuitable for bundling
        w - waiting to be aggregated
        d - default port

Number of channel-groups in use: 1
Number of aggregators:           1

Group  Port-channel  Protocol    Ports
──────+─────────────+───────────+─────────────────────────────────────────
1      Po1(SU)       LACP        Gi0/1(P)   Gi0/2(P)   Gi0/3(P)

Switch# show etherchannel 1 detail
Switch# show interfaces port-channel 1
```

### EtherChannel Load Balancing

By default, Cisco uses **src-dst-mac** for load balancing (Layer 2) or **src-dst-ip** (Layer 3).

```
! Check current load-balance method
Switch# show etherchannel load-balance
  EtherChannel Load-Balancing Operational State (src-dst-mac):
  Non-IP: Source XOR Destination MAC address

! Change load-balance method
Switch(config)# port-channel load-balance src-dst-ip

! Load balance options:
!   dst-ip, dst-mac, src-dst-ip, src-dst-mac, src-ip, src-mac
```

> **Exam Tip:** EtherChannel requirements — all physical ports must have the SAME: speed, duplex, VLAN configuration, trunk/access mode. Mismatched config will prevent channel formation.

---

## 9. Wireless Fundamentals

### 802.11 Standards

| Standard | Band | Max Speed | Notes |
|----------|------|-----------|-------|
| 802.11a | 5 GHz | 54 Mbps | Less interference, shorter range |
| 802.11b | 2.4 GHz | 11 Mbps | Legacy |
| 802.11g | 2.4 GHz | 54 Mbps | Backward compatible with b |
| 802.11n (Wi-Fi 4) | 2.4/5 GHz | 600 Mbps | MIMO, multiple spatial streams |
| 802.11ac (Wi-Fi 5) | 5 GHz only | 6.9 Gbps | MU-MIMO, wider channels |
| 802.11ax (Wi-Fi 6) | 2.4/5/6 GHz | 9.6 Gbps | OFDMA, BSS Coloring |

### Frequency Bands

**2.4 GHz:**
- 3 non-overlapping channels: 1, 6, 11
- Greater range, more penetration
- More interference (microwaves, Bluetooth, baby monitors)
- More crowded (most devices use 2.4 GHz)

**5 GHz:**
- 24+ non-overlapping channels (varies by country)
- Less range, less wall penetration
- Less interference, higher throughput

```
2.4 GHz Channel Layout (overlapping channels):
──────────────────────────────────────────────
Ch 1: ████████████
Ch 2:  ████████████
Ch 3:   ████████████
Ch 4:    ████████████
Ch 5:     ████████████
Ch 6:      ████████████
Ch 7:       ████████████
Ch 8:        ████████████
Ch 9:         ████████████
Ch 10:          ████████████
Ch 11:           ████████████

Only 1, 6, and 11 don't overlap with each other!
```

### Wireless Topologies

**Ad-hoc (IBSS)** — Direct device-to-device, no AP. Rare.

**Infrastructure (BSS)** — Devices connect to a single AP.
```
[Laptop]─── [AP] ───[Switch]───[Router]
  SSID: CorpNet
  BSS: Single cell
```

**ESS (Extended Service Set)** — Multiple APs with same SSID.
```
          [AP1]         [AP2]         [AP3]
    ┌─────────────────────────────────────┐
    │              Same SSID             │
    └───────────────[Switch]─────────────┘
    Roaming: Device moves between APs seamlessly
```

**SSID** — Service Set Identifier. The network name.
**BSSID** — MAC address of the AP radio.

### Wireless Architectures

**Autonomous AP:**
- Standalone — all configuration on the AP itself
- No central management
- Good for small/home networks

**Lightweight AP + WLC (Wireless LAN Controller):**
- Split-MAC architecture
- Real-time functions on AP, management on WLC
- CAPWAP (Control and Provisioning of Wireless Access Points) tunnel between AP and WLC
- Centralized management, firmware, configuration

```
LIGHTWEIGHT AP + WLC ARCHITECTURE:
───────────────────────────────────────────────────────

[Laptop] ─── wireless ─── [LAP] ═══ CAPWAP ══ [WLC]
                                    UDP 5246/5247

The LAP (Lightweight AP):
  - Handles RF (radio), client association, encryption

The WLC handles:
  - SSID config, security policy, roaming
  - RF management, firmware updates
  - Client authentication
```

**CAPWAP Ports:**
- UDP 5246 — Control channel (management)
- UDP 5247 — Data channel

**FlexConnect (Hybrid):**
- AP can switch traffic locally if WLC connection fails
- Good for branch offices

### Wireless Channel Selection

```
! On WLC: Configure RF Management
! Auto channel assignment via RRM (Radio Resource Management)
! Or manually set channels to minimize interference

! Best practices:
! - Use 1, 6, 11 on 2.4 GHz
! - Use 40 MHz or 80 MHz channels on 5 GHz
! - Avoid co-channel interference (same channel adjacent APs)
! - Plan cell coverage — 15-20% overlap between cells for roaming
```

---

## 10. Wireless Security

### Evolution of Wireless Security

| Protocol | Year | Key Size | Notes |
|----------|------|----------|-------|
| WEP | 1997 | 40/104-bit | Broken — never use |
| WPA | 2003 | 128-bit (TKIP) | Interim fix — avoid |
| WPA2 | 2004 | 128-bit (AES/CCMP) | Current standard |
| WPA3 | 2018 | 192-bit (GCMP-256) | Latest, best |

### WPA2 Modes

**WPA2-Personal (PSK):**
- Pre-shared key — same password for all users
- Good for home and small networks
- All users share same key = security risk in enterprise

**WPA2-Enterprise (802.1X):**
- Unique credentials per user (username/password or certificates)
- Uses RADIUS server for authentication
- EAP (Extensible Authentication Protocol) used for auth
- Required for enterprise environments

```
WPA2-Enterprise Authentication Flow:
──────────────────────────────────────────────────────

[Client]────[AP]────────[WLC]────────[RADIUS Server]
   │            CAPWAP tunnel             │
   │──EAP Request───────────────────────→│
   │←─EAP Identity Request───────────────│
   │──EAP Identity (username)───────────→│
   │←─EAP Challenge──────────────────────│
   │──EAP Response (credentials)────────→│
   │←─EAP Success (+ session key)────────│
   │←─Association Complete───────────────│
   │        [Encrypted Data]             │
```

### EAP Methods

| EAP Type | Auth Method | Certificate Required |
|----------|-------------|---------------------|
| EAP-TLS | Client cert + Server cert | Both sides |
| PEAP | Server cert + MSCHAPv2 | Server only |
| EAP-FAST | PAC file | None (optional) |
| EAP-TTLS | Server cert + various | Server only |

### Configuring WLAN in WLC (GUI Steps)

CCNA expects you to know basic WLC WLAN configuration:

1. Log into WLC GUI (HTTPS)
2. Navigate to **WLANs** → **Create New**
3. Set Profile Name and SSID
4. Under **Security** tab:
   - Layer 2 Security: **WPA+WPA2**
   - WPA2 Policy: **AES** (CCMP)
   - Auth Key Management: **PSK** (personal) or **802.1X** (enterprise)
5. Under **Advanced** tab:
   - Enable **FlexConnect Local Switching** if needed
6. Under **QoS** tab:
   - Set Quality of Service profile
7. Map WLAN to interface (VLAN)
8. Apply and Enable

```
! CLI configuration on WLC (less common — GUI preferred):
(Cisco Controller)> config wlan create 1 CorpNet CorpNet
(Cisco Controller)> config wlan security wpa akm psk set-key ascii 0 MyPassword123 1
(Cisco Controller)> config wlan enable 1
(Cisco Controller)> show wlan 1
```

> **Exam Tip:** Know WPA2 vs WPA3, Personal vs Enterprise, and when to use each. CCNA expects you to understand the WLC GUI workflow and know that WPA2/AES (CCMP) is the minimum recommended security standard.

---

## Chapter 2 Summary

| Topic | Key Points |
|-------|-----------|
| VLANs | Logical segmentation, VLAN IDs 1-4094, access vs trunk ports |
| 802.1Q | 4-byte tag, native VLAN untagged, DTP for negotiation |
| Inter-VLAN | ROAS (subinterfaces) or L3 switch SVIs + ip routing |
| STP | Root bridge election, port roles, 50s convergence |
| Rapid PVST+ | 802.1w, 3 states, ~1-2s convergence |
| EtherChannel | LACP (active/passive), PAgP (desirable/auto), or static |
| Wireless | 802.11 standards, 2.4/5 GHz bands, infrastructure vs autonomous |
| Wireless Security | WPA2-Personal (PSK) vs WPA2-Enterprise (802.1X/RADIUS) |

---

*[← Chapter 1](01-network-fundamentals.md) | [Chapter 3: IP Connectivity →](03-ip-connectivity.md)*
# Chapter 3: IP Connectivity

> **Exam Weight: 25% — The highest-weighted domain on the CCNA exam.**

---

## Table of Contents
1. [Routing Fundamentals](#1-routing-fundamentals)
2. [Routing Table](#2-routing-table)
3. [Administrative Distance](#3-administrative-distance)
4. [Static Routing](#4-static-routing)
5. [IPv6 Static Routing](#5-ipv6-static-routing)
6. [OSPFv2](#6-ospfv2)
7. [OSPFv3 (IPv6)](#7-ospfv3-ipv6)
8. [FHRP — First Hop Redundancy Protocols](#8-fhrp---first-hop-redundancy-protocols)

---

## 1. Routing Fundamentals

### How a Router Makes a Forwarding Decision

When a packet arrives:

1. **Check destination IP** in packet header
2. **Look up routing table** — find longest prefix match (most specific route)
3. **If match found** → forward out the exit interface to the next-hop IP
4. **If no match** → use default route (if configured), or drop and send ICMP unreachable

```
ROUTING DECISION — LONGEST PREFIX MATCH:
─────────────────────────────────────────
Routing Table:
  10.0.0.0/8      via Gi0/0
  10.1.0.0/16     via Gi0/1
  10.1.1.0/24     via Gi0/2
  0.0.0.0/0       via Gi0/3  (default)

Packet arriving for 10.1.1.5:
  Match 10.0.0.0/8?    Yes (8-bit match)
  Match 10.1.0.0/16?   Yes (16-bit match)
  Match 10.1.1.0/24?   YES (24-bit match) ← LONGEST PREFIX WINS
  → Forward via Gi0/2
```

### Routed vs Routing Protocol

- **Routed protocol** — carries user data (IP, IPv6)
- **Routing protocol** — helps routers exchange network information (OSPF, EIGRP, BGP)

### Route Sources

| Source | How Learned |
|--------|-------------|
| **Directly connected** | Interface configured with IP and up/up |
| **Static** | Manually configured by administrator |
| **Dynamic** | Learned via routing protocol (OSPF, EIGRP, BGP, etc.) |

---

## 2. Routing Table

```
! Show routing table
Router# show ip route

Codes: L - local, C - connected, S - static, R - RIP, M - mobile, B - BGP
       D - EIGRP, EX - EIGRP external, O - OSPF, IA - OSPF inter area
       N1 - OSPF NSSA external type 1, N2 - OSPF NSSA external type 2
       E1 - OSPF external type 1, E2 - OSPF external type 2
       i - IS-IS, su - IS-IS summary, L1 - IS-IS level-1, L2 - IS-IS level-2
       ia - IS-IS inter area, * - candidate default, U - per-user static route
       o - ODR, P - periodic downloaded static route, H - NHRP, l - LISP
       a - application route
       + - replicated route, % - next hop override, p - overrides from PfR

Gateway of last resort is 203.0.113.1 to network 0.0.0.0

S*    0.0.0.0/0 [1/0] via 203.0.113.1       ← Default route, AD=1, metric=0
C     10.1.1.0/24 is directly connected, GigabitEthernet0/0
L     10.1.1.1/32 is directly connected, GigabitEthernet0/0   ← /32 = local addr
C     10.1.2.0/24 is directly connected, GigabitEthernet0/1
L     10.1.2.1/32 is directly connected, GigabitEthernet0/1
O     10.2.0.0/16 [110/2] via 10.1.1.2, 00:05:13, GigabitEthernet0/0  ← OSPF
S     172.16.0.0/16 [1/0] via 10.1.2.254                     ← Static route
```

### Reading a Route Entry

```
O     10.2.0.0/16 [110/2] via 10.1.1.2, 00:05:13, GigabitEthernet0/0
│     │            │   │       │          │          │
│     │            │   │       │          │          └── Exit interface
│     │            │   │       │          └──────────── Time since learned
│     │            │   │       └─────────────────────── Next-hop IP
│     │            │   └─────────────────────────────── Metric (OSPF cost)
│     │            └─────────────────────────────────── AD (110 = OSPF)
│     └──────────────────────────────────────────────── Destination network
└────────────────────────────────────────────────────── Route source (O=OSPF)
```

---

## 3. Administrative Distance

When multiple routing sources provide routes to the same destination, the router uses the route with the **lowest Administrative Distance (AD)**.

| Route Source | AD |
|-------------|-----|
| Directly connected | **0** |
| Static route | **1** |
| EIGRP Summary | 5 |
| External BGP (eBGP) | 20 |
| EIGRP (internal) | **90** |
| OSPF | **110** |
| IS-IS | 115 |
| RIP | 120 |
| EIGRP (external) | 170 |
| Internal BGP (iBGP) | 200 |
| Unreachable/Unknown | 255 |

> **Exam Tip:** Memorize: Connected=0, Static=1, EIGRP=90, OSPF=110, RIP=120. AD is a "trustworthiness" rating — lower = more trusted.

---

## 4. Static Routing

### Types of Static Routes

| Type | Description | Use Case |
|------|-------------|----------|
| **Standard static** | Specific network via next-hop or interface | Any single path |
| **Default static** | 0.0.0.0/0 — catch-all | Internet gateway |
| **Floating static** | Higher AD backup route | Redundancy |
| **Summary static** | One route covers multiple subnets | Simplify routing table |
| **Host static** | /32 route to specific host | Specific host path |

### Static Route Configuration

```
! Basic static route — next-hop IP (preferred)
Router(config)# ip route 10.2.0.0 255.255.0.0 10.1.1.2

! Static route — exit interface only (use on point-to-point links)
Router(config)# ip route 10.2.0.0 255.255.0.0 GigabitEthernet0/1

! Static route — both next-hop and exit interface
Router(config)# ip route 10.2.0.0 255.255.0.0 GigabitEthernet0/1 10.1.1.2

! Default static route
Router(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.1

! Floating static (backup) — AD of 5 (higher than primary)
! Primary route learned via OSPF (AD=110), this only installs if OSPF fails
Router(config)# ip route 10.2.0.0 255.255.0.0 10.1.2.1 115

! Host route (/32)
Router(config)# ip route 10.5.5.5 255.255.255.255 10.1.1.2

! Verify static routes
Router# show ip route static

S     0.0.0.0/0 [1/0] via 203.0.113.1
S     10.2.0.0/16 [1/0] via 10.1.1.2
S     10.5.5.5/32 [1/0] via 10.1.1.2
```

### Static Route Lab Scenario

```
TOPOLOGY:
─────────────────────────────────────────────────────────────────
PC1 (10.1.1.10)                                PC2 (10.3.3.10)
   │                                                │
[SW1]──[R1]────────────────────────────[R2]──[SW2]
   │   Gi0/0: 10.1.1.1/24   10.2.2.1/30  Gi0/1: 10.3.3.1/24
              Gi0/1: 10.2.2.1/30  10.2.2.2/30
─────────────────────────────────────────────────────────────────

R1 Configuration:
  ! Interfaces
  R1(config)# interface GigabitEthernet0/0
  R1(config-if)# ip address 10.1.1.1 255.255.255.0
  R1(config-if)# no shutdown
  R1(config-if)# exit

  R1(config)# interface GigabitEthernet0/1
  R1(config-if)# ip address 10.2.2.1 255.255.255.252
  R1(config-if)# no shutdown
  R1(config-if)# exit

  ! Static route to reach 10.3.3.0/24 via R2
  R1(config)# ip route 10.3.3.0 255.255.255.0 10.2.2.2

R2 Configuration:
  ! Interfaces
  R2(config)# interface GigabitEthernet0/0
  R2(config-if)# ip address 10.2.2.2 255.255.255.252
  R2(config-if)# no shutdown
  R2(config-if)# exit

  R2(config)# interface GigabitEthernet0/1
  R2(config-if)# ip address 10.3.3.1 255.255.255.0
  R2(config-if)# no shutdown
  R2(config-if)# exit

  ! Static route to reach 10.1.1.0/24 via R1
  R2(config)# ip route 10.1.1.0 255.255.255.0 10.2.2.1

Verify:
  R1# ping 10.3.3.10 source 10.1.1.1
  R1# traceroute 10.3.3.10
  R1# show ip route
```

---

## 5. IPv6 Static Routing

```
! Enable IPv6 routing (required!)
Router(config)# ipv6 unicast-routing

! Configure IPv6 interfaces
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ipv6 address 2001:DB8:1:1::1/64
Router(config-if)# no shutdown

! IPv6 static route via next-hop
Router(config)# ipv6 route 2001:DB8:3:3::/64 2001:DB8:2:2::2

! IPv6 default route
Router(config)# ipv6 route ::/0 2001:DB8:2:2::2

! IPv6 static route via interface (link-local next-hop requires interface)
Router(config)# ipv6 route 2001:DB8:3:3::/64 GigabitEthernet0/1 FE80::2

! Verify
Router# show ipv6 route
Router# show ipv6 route static
```

---

## 6. OSPFv2

**OSPF (Open Shortest Path First)** is a link-state, classless, interior gateway routing protocol. It uses **Dijkstra's SPF (Shortest Path First)** algorithm to calculate the best path.

### OSPF Key Concepts

| Concept | Value |
|---------|-------|
| Protocol | IP protocol 89 |
| AD | 110 |
| Metric | **Cost** (Reference BW / Interface BW) |
| Default Reference BW | 100 Mbps |
| Hello interval (default) | 10 sec (broadcast), 30 sec (NBMA) |
| Dead interval (default) | 4× Hello = 40 sec (broadcast) |
| Algorithm | Dijkstra SPF |
| Update type | LSA flooding (reliable — uses sequence numbers) |
| Multicast | 224.0.0.5 (all OSPF routers), 224.0.0.6 (DR/BDR) |

### OSPF Cost Calculation

```
Cost = Reference Bandwidth / Interface Bandwidth

Default reference bandwidth = 100 Mbps

Interface     Speed      Cost
──────────────────────────────
Ethernet      10 Mbps    10      (100/10)
FastEthernet  100 Mbps   1       (100/100)
GigabitEth    1000 Mbps  1       (100/1000, rounds to 1)
10 GigabitEth 10000 Mbps 1       (100/10000, rounds to 1)
```

> **Problem:** Default reference BW can't differentiate between 100Mbps, 1Gbps, 10Gbps (all cost=1). Solution: Change reference BW.

```
! Change reference bandwidth on ALL OSPF routers in the domain
Router(config-router)# auto-cost reference-bandwidth 10000
! Now: FastEth=100, GigEth=10, 10GigEth=1
```

### OSPF Areas

OSPF uses a **hierarchical area design**. Area 0 (backbone) is required.

```
                    ┌─────────────────┐
                    │    Area 0       │
                    │   (Backbone)    │
                    │  [ABR]──[ABR]  │
                    └────┬──────┬────┘
                         │      │
             ┌───────────┘      └────────────┐
             │                               │
        ┌────┴────┐                    ┌─────┴───┐
        │ Area 1  │                    │ Area 2  │
        │[R1][R2] │                    │[R3][R4] │
        └─────────┘                    └─────────┘

ABR (Area Border Router) — connects one area to Area 0
ASBR (Autonomous System Boundary Router) — connects OSPF to other routing domains
```

Single-area OSPF (all in Area 0) is common for smaller networks and what CCNA focuses on.

### OSPF Neighbor States (Adjacency Formation)

```
OSPF NEIGHBOR STATE MACHINE:
─────────────────────────────────────────────────────────────────
Down → Init → 2-Way → ExStart → Exchange → Loading → Full

Down:     No Hello received
Init:     Hello received, but my RID not in neighbor's Hello
2-Way:    My RID seen in neighbor's Hello (bidirectional)
          ↑ DR/BDR election happens HERE on broadcast networks
ExStart:  Master/Slave negotiation for DBD exchange
Exchange: DBD (Database Description) packets exchanged
Loading:  LSR/LSU/LSAck — requesting and receiving full LSAs
Full:     Databases synchronized — OSPF fully adjacent ✓
```

### DR and BDR Election (Broadcast Networks)

On Ethernet, OSPF elects a **Designated Router (DR)** and **Backup Designated Router (BDR)** to reduce flooding.

- Non-DR/BDR routers form full adjacency only with DR and BDR (not each other)
- Non-DR/BDR = **DROTHER** — stay in **2-Way** state with each other

**Election criteria:**
1. Highest **OSPF priority** (default 1, range 0-255; 0 = no election participation)
2. Tie → Highest **Router ID (RID)**

**Router ID determination:**
1. Manually configured RID (`router-id x.x.x.x`)
2. Highest IP on a **loopback interface**
3. Highest IP on any **active physical interface**

> **Important:** DR/BDR election is **non-preemptive** — once elected, stays until OSPF process restarts, even if a router with better priority joins.

### OSPFv2 Configuration

```
! Basic single-area OSPF
Router(config)# router ospf 1                      ! 1 = process ID (local significance only)
Router(config-router)# router-id 1.1.1.1           ! Manually set RID (best practice)
Router(config-router)# network 10.1.1.0 0.0.0.255 area 0   ! wildcard mask
Router(config-router)# network 10.2.2.0 0.0.0.3 area 0
Router(config-router)# passive-interface GigabitEthernet0/0  ! don't send Hellos to LAN

! OR configure OSPF directly on the interface (preferred modern method)
Router(config)# router ospf 1
Router(config-router)# router-id 1.1.1.1

Router(config)# interface GigabitEthernet0/0
Router(config-if)# ip ospf 1 area 0               ! enable OSPF on this interface

Router(config)# interface GigabitEthernet0/1
Router(config-if)# ip ospf 1 area 0

! Change reference bandwidth (ALL routers must match)
Router(config-router)# auto-cost reference-bandwidth 1000    ! 1000 Mbps reference

! Manually set interface cost
Router(config-if)# ip ospf cost 5

! Change OSPF priority (for DR/BDR election)
Router(config-if)# ip ospf priority 100             ! higher wins, 0 = never DR/BDR

! Change Hello and Dead timers (must match on both ends!)
Router(config-if)# ip ospf hello-interval 5
Router(config-if)# ip ospf dead-interval 20

! Advertise default route into OSPF (requires default route to exist)
Router(config-router)# default-information originate

! OR force advertising even without a default route
Router(config-router)# default-information originate always
```

### OSPF Verification

```
! Show OSPF neighbors
Router# show ip ospf neighbor

Neighbor ID     Pri   State           Dead Time   Address         Interface
2.2.2.2           1   FULL/DR         00:00:37    10.1.1.2        Gi0/0
3.3.3.3           1   FULL/BDR        00:00:39    10.1.1.3        Gi0/0
4.4.4.4           1   FULL/DROTHER    00:00:35    10.1.1.4        Gi0/0

! Note: "FULL/DR" = neighbor IS the DR and we have FULL adjacency
!       "2WAY/DROTHER" = neighbor is a DROther, 2-Way state only

! Show OSPF interface info
Router# show ip ospf interface GigabitEthernet0/0

GigabitEthernet0/0 is up, line protocol is up
  Internet Address 10.1.1.1/24 Area 0, Attached via Interface Enable
  Process ID 1, Router ID 1.1.1.1, Network Type BROADCAST, Cost: 1
  Transmit Delay is 1 sec, State BDR, Priority 1
  Designated Router (ID) 2.2.2.2, Interface address 10.1.1.2
  Backup Designated router (ID) 1.1.1.1, Interface address 10.1.1.1
  Timer intervals configured, Hello 10, Dead 40, Wait 40, Retransmit 5
  Hello due in 00:00:04
  Neighbor Count is 2, Adjacent neighbor count is 2
  Adjacent with neighbor 2.2.2.2  (Designated Router)

! Show OSPF routing table entries
Router# show ip route ospf

      10.0.0.0/8 is variably subnetted, 6 subnets, 3 masks
O        10.2.2.0/30 [110/2] via 10.1.1.2, 00:10:13, GigabitEthernet0/0
O        10.3.3.0/24 [110/3] via 10.1.1.2, 00:10:13, GigabitEthernet0/0

! Show OSPF process details
Router# show ip ospf

 Routing Process "ospf 1" with ID 1.1.1.1
 Start time: 00:01:23.456, Time elapsed: 00:10:13.123
 Supports only single TOS(TOS0) routes
 Supports opaque LSA
 It is an area border router
  ...

! Show OSPF database (LSDB)
Router# show ip ospf database

! Clear OSPF process (forces re-election, use in lab only)
Router# clear ip ospf process
```

### OSPF Network Types

| Network Type | Routers | DR/BDR | Hello |
|-------------|---------|--------|-------|
| **Broadcast** | Multiple | Yes | 10 sec |
| **Point-to-Point** | 2 | No | 10 sec |
| **NBMA** | Multiple | Yes | 30 sec |
| **Point-to-Multipoint** | Multiple | No | 30 sec |

```
! Ethernet is Broadcast by default — change to P2P on links with only 2 routers
! (eliminates DR/BDR overhead)
Router(config-if)# ip ospf network point-to-point
```

### OSPF Full Configuration Example

```
TOPOLOGY:
─────────────────────────────────────────────────────────
     Lo0: 1.1.1.1/32          Lo0: 2.2.2.2/32
         │                        │
[R1]─────┤──────10.12.0.0/30──────┤─────[R2]
 Gi0/0: 10.12.0.1/30   Gi0/0: 10.12.0.2/30
 Gi0/1: 10.1.1.1/24    Gi0/1: 10.2.2.1/24
         │                        │
      [LAN1]                   [LAN2]
   10.1.1.0/24              10.2.2.0/24
─────────────────────────────────────────────────────────

R1:
  interface Loopback0
   ip address 1.1.1.1 255.255.255.255
  interface GigabitEthernet0/0
   ip address 10.12.0.1 255.255.255.252
   ip ospf 1 area 0
   no shutdown
  interface GigabitEthernet0/1
   ip address 10.1.1.1 255.255.255.0
   ip ospf 1 area 0
   no shutdown
  router ospf 1
   router-id 1.1.1.1
   auto-cost reference-bandwidth 1000
   passive-interface GigabitEthernet0/1   ! don't send hellos to LAN
   network 1.1.1.1 0.0.0.0 area 0        ! include loopback

R2:
  interface Loopback0
   ip address 2.2.2.2 255.255.255.255
  interface GigabitEthernet0/0
   ip address 10.12.0.2 255.255.255.252
   ip ospf 1 area 0
   no shutdown
  interface GigabitEthernet0/1
   ip address 10.2.2.1 255.255.255.0
   ip ospf 1 area 0
   no shutdown
  router ospf 1
   router-id 2.2.2.2
   auto-cost reference-bandwidth 1000
   passive-interface GigabitEthernet0/1
   network 2.2.2.2 0.0.0.0 area 0
```

---

## 7. OSPFv3 (IPv6)

OSPFv3 is OSPF for IPv6. Works similarly to OSPFv2 but:
- Uses **link-local addresses** for neighbor communication
- Supports **IPv6 addressing**
- Uses **FE80::/10** link-local multicast

```
! Enable IPv6 routing
Router(config)# ipv6 unicast-routing

! Configure OSPFv3
Router(config)# ipv6 router ospf 1
Router(config-rtr)# router-id 1.1.1.1

! Enable OSPFv3 on interfaces
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ipv6 ospf 1 area 0

! Verify
Router# show ipv6 ospf neighbor
Router# show ipv6 route ospf
Router# show ipv6 ospf database
```

---

## 8. FHRP — First Hop Redundancy Protocols

**Problem:** End devices use a static default gateway. If that gateway router fails, traffic stops — even if there's another router available.

**Solution:** FHRPs present a **virtual IP and MAC** that multiple routers share. End devices use the virtual IP as their gateway. If the active router fails, the standby takes over transparently.

```
PROBLEM (No FHRP):
──────────────────────────────────────────────────────
[PC] default gateway: 10.1.1.1 (R1 only)
         │
    [R1] ← FAILS                [R2] (never used as gateway)
         │                       │
         └──────[SWITCH]─────────┘
Traffic stops if R1 fails!

SOLUTION (FHRP):
──────────────────────────────────────────────────────
[PC] default gateway: 10.1.1.254 (VIRTUAL IP — shared)
         │
    [R1] Active/Master    [R2] Standby/Backup
    10.1.1.1              10.1.1.2
    Virtual: 10.1.1.254   Virtual: 10.1.1.254
         │                     │
         └────[SWITCH]──────────┘
If R1 fails, R2 takes over VIP automatically!
```

### FHRP Comparison

| Feature | HSRP | VRRP | GLBP |
|---------|------|------|------|
| Standard | Cisco proprietary | IEEE 802.118 | Cisco proprietary |
| Active router | Active | Master | Active Virtual Gateway |
| Standby router | Standby | Backup | Active Virtual Forwarder |
| Load balancing | No (1 active) | No (1 master) | Yes (up to 4) |
| Virtual MAC | 0000.0c07.acXX | 0000.5e00.01XX | 0007.b400.XXYY |
| Preemption | Default OFF | Default ON | Default OFF |
| Auth support | MD5/plain text | MD5 | MD5/plain text |

### HSRP (Hot Standby Router Protocol)

Cisco proprietary. Two versions: **HSRPv1** (IPv4 only) and **HSRPv2** (IPv4 + IPv6).

```
! HSRP Configuration on R1 (Active)
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ip address 10.1.1.1 255.255.255.0
Router(config-if)# standby version 2                         ! use HSRPv2
Router(config-if)# standby 1 ip 10.1.1.254                  ! group 1, VIP
Router(config-if)# standby 1 priority 110                   ! higher priority = active (default 100)
Router(config-if)# standby 1 preempt                        ! take back active if we recover
Router(config-if)# standby 1 preempt delay minimum 30       ! wait 30s before preempting
Router(config-if)# standby 1 authentication md5 key-string MyHSRP  ! optional auth

! HSRP Interface Tracking (reduce priority if WAN goes down)
Router(config-if)# standby 1 track GigabitEthernet0/1 20   ! reduce priority by 20 if Gi0/1 fails

! HSRP Configuration on R2 (Standby)
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ip address 10.1.1.2 255.255.255.0
Router(config-if)# standby version 2
Router(config-if)# standby 1 ip 10.1.1.254
Router(config-if)# standby 1 priority 90                    ! lower = standby
Router(config-if)# standby 1 preempt

! Verify HSRP
Router# show standby

GigabitEthernet0/0 - Group 1 (version 2)
  State is Active
    1 state change, last state change 00:05:32
  Virtual IP address is 10.1.1.254
  Active virtual MAC address is 0000.0c9f.f001 (MAC In Use)
    Local virtual MAC address is 0000.0c9f.f001 (v2 default)
  Hello time 3 sec, hold time 10 sec
    Next hello sent in 1.680 secs
  Preemption enabled
  Active router is local
  Standby router is 10.1.1.2, priority 90 (expires in 9.472 sec)
  Priority 110 (configured 110)
  Group name is "hsrp-Gi0/0-1"  (default)

Router# show standby brief

                     P indicates configured to preempt.
                     |
Interface   Grp  Pri P State    Active          Standby         Virtual IP
Gi0/0         1  110 P Active   local           10.1.1.2        10.1.1.254
```

### HSRP States

```
HSRP State Machine:
───────────────────────────────────────────────────────────
Initial → Learn → Listen → Speak → Standby → Active

Initial:  Interface just came up
Learn:    VIP not known, waiting for Active to announce
Listen:   VIP known, waiting
Speak:    Sending Hellos, participating in election
Standby:  Backup router — ready to take over
Active:   Currently forwarding traffic for VIP
```

### VRRP (Virtual Router Redundancy Protocol)

IEEE open standard. Very similar to HSRP.

```
! VRRP Configuration on R1 (Master)
Router(config)# interface GigabitEthernet0/0
Router(config-if)# vrrp 1 ip 10.1.1.254
Router(config-if)# vrrp 1 priority 110
Router(config-if)# vrrp 1 preempt
Router(config-if)# vrrp 1 authentication md5 key-string MyVRRP

! Verify VRRP
Router# show vrrp
Router# show vrrp brief
```

**Key VRRP difference from HSRP:**
- Default preemption is ON in VRRP (OFF in HSRP)
- The virtual MAC format is different: `0000.5e00.01XX`

### GLBP (Gateway Load Balancing Protocol)

Cisco proprietary. Provides **actual load balancing** — multiple routers actively forward traffic.

```
! GLBP Configuration
Router(config)# interface GigabitEthernet0/0
Router(config-if)# glbp 1 ip 10.1.1.254
Router(config-if)# glbp 1 priority 110
Router(config-if)# glbp 1 preempt
Router(config-if)# glbp 1 load-balancing round-robin  ! or: host-dependent, weighted

! Verify GLBP
Router# show glbp
Router# show glbp brief
```

**GLBP roles:**
- **AVG (Active Virtual Gateway)** — assigns virtual MACs to each router
- **AVF (Active Virtual Forwarder)** — each router gets a unique virtual MAC
- All AVFs forward traffic simultaneously = load balancing

---

## Chapter 3 Summary

| Topic | Key Points |
|-------|-----------|
| Routing | Longest prefix match wins, AD determines best source |
| Static routes | `ip route` — standard, default (0.0.0.0/0), floating |
| OSPF | Link-state, cost metric, Area 0 backbone, DR/BDR on broadcast |
| OSPF config | `network` + wildcard OR `ip ospf process area` per interface |
| OSPF neighbors | Full adjacency required, verify with `show ip ospf neighbor` |
| FHRP | VIP shared between routers — HSRP (Cisco), VRRP (IEEE), GLBP (load balance) |
| HSRP | Priority 100 default, higher = active, preempt is OFF by default |

---

*[← Chapter 2](02-network-access.md) | [Chapter 4: IP Services →](04-ip-services.md)*
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
# Chapter 6: Automation and Programmability

> **Exam Weight: 10%**

---

## Table of Contents
1. [Traditional vs Controller-Based Networking](#1-traditional-vs-controller-based-networking)
2. [SDN Architecture](#2-sdn-architecture)
3. [Cisco DNA Center](#3-cisco-dna-center)
4. [REST APIs](#4-rest-apis)
5. [Data Formats: JSON, XML, YAML](#5-data-formats-json-xml-yaml)
6. [Configuration Management Tools](#6-configuration-management-tools)

---

## 1. Traditional vs Controller-Based Networking

### Traditional Networking

In traditional networks, every device is individually configured. The control plane (routing/switching decisions) and data plane (forwarding) are both on the device.

```
TRADITIONAL NETWORK:
────────────────────────────────────────────────────────────────────────

Each device is individually configured:

[R1]                [R2]                [R3]
 │                   │                   │
 ├─ Config stored    ├─ Config stored    ├─ Config stored
 ├─ Routing tables   ├─ Routing tables   ├─ Routing tables
 └─ Forwards data    └─ Forwards data    └─ Forwards data

Administrator SSHs to each device separately.
Changes require device-by-device configuration.
Human error risk is high.
```

**Problems with traditional approach:**
- **Slow changes** — manual SSH to each device
- **Inconsistency** — human error across many devices
- **Lack of visibility** — no single view of entire network
- **Complex troubleshooting** — log into each device individually
- **Vendor lock-in** — proprietary CLI per vendor

### Controller-Based Networking

A **centralized controller** manages the network. The control plane is moved to the controller; devices only forward traffic.

```
CONTROLLER-BASED NETWORK:
────────────────────────────────────────────────────────────────────────

             ┌──────────────────────────────────────┐
             │         CONTROLLER (SDN)              │
             │   Central intelligence, policy,       │
             │   topology view, configuration        │
             └────────────┬─────────────────────────┘
                          │ Southbound APIs
              ┌───────────┼───────────┐
             [R1]        [R2]        [R3]
           (Dumb      (Dumb       (Dumb
           forwarder) forwarder)  forwarder)

Single configuration point. Push changes to all devices at once.
Controller has complete network view.
```

### Control Plane vs Data Plane

| Plane | Function | Traditional Location | SDN Location |
|-------|----------|---------------------|--------------|
| **Control Plane** | Routing decisions, STP, topology | Local on device | Centralized controller |
| **Data Plane** | Actual packet forwarding | Local on device | Local on device (hardware) |
| **Management Plane** | SSH, SNMP, configuration | Local on device | Controller + direct |

---

## 2. SDN Architecture

**SDN (Software-Defined Networking)** separates the control and data planes.

```
SDN ARCHITECTURE LAYERS:
────────────────────────────────────────────────────────────────────────

┌──────────────────────────────────────────────────────────────┐
│  APPLICATION LAYER                                            │
│  Network apps: Security policies, Load balancing, QoS,       │
│  Analytics, Provisioning systems                              │
│                  ↕ Northbound API (REST, Java)                │
├──────────────────────────────────────────────────────────────┤
│  CONTROL LAYER (SDN Controller)                               │
│  - Network operating system                                   │
│  - Topology and state database                                │
│  - Path calculation                                           │
│  - Policy enforcement                                         │
│                  ↕ Southbound API (OpenFlow, NETCONF, RESTCONF│
├──────────────────────────────────────────────────────────────┤
│  INFRASTRUCTURE LAYER (Network Devices)                       │
│  Routers, switches, APs — forward traffic based on           │
│  instructions from controller                                 │
└──────────────────────────────────────────────────────────────┘
```

### SDN APIs

**Northbound APIs** — Between controller and applications (NMS, automation scripts)
- REST APIs (HTTP/JSON)
- Used by: network management apps, automation tools, scripts

**Southbound APIs** — Between controller and network devices
- **OpenFlow** — Original SDN protocol, programs forwarding tables
- **NETCONF** — Network Configuration Protocol (RFC 6241), uses XML over SSH
- **RESTCONF** — HTTP-based NETCONF (subset), uses JSON/XML
- **gRPC/gNMI** — Google RPC, used in modern telemetry and config

**East-West APIs** — Between controllers (peer communication)

### Overlay, Underlay, and Fabric

| Term | Description |
|------|-------------|
| **Underlay** | Physical network — the actual physical links and devices |
| **Overlay** | Virtual/logical network built on top of underlay (tunnels, VXLANs) |
| **Fabric** | The combination of underlay + overlay + controller |

```
CISCO SD-ACCESS FABRIC:
────────────────────────────────────────────────────────────────────────

OVERLAY (virtual)      : VXLAN tunnels for data, LISP for control
UNDERLAY (physical)    : IP-routed physical network (spine-leaf)
CONTROLLER             : Cisco DNA Center orchestrates both layers

End devices connect to edge nodes, which encapsulate in VXLAN tunnels.
Traffic flows over IP underlay. Controller manages policies centrally.
```

---

## 3. Cisco DNA Center

**Cisco DNA Center** (DNAC) is Cisco's SDN controller for enterprise campus and branch networks.

```
┌─────────────────────────────────────────────────────────────────┐
│                    CISCO DNA CENTER                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │   Design    │  │   Policy    │  │     Provision           │ │
│  │ Network     │  │ Group-based │  │  Automated device       │ │
│  │ hierarchy   │  │ access ctrl │  │  onboarding & config    │ │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘ │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │  Assurance  │  │  Platform   │  │      Security           │ │
│  │ AI/ML-based │  │ APIs for    │  │  Encrypted traffic      │ │
│  │ analytics   │  │ integration │  │  analysis               │ │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### DNA Center vs Traditional Management

| Feature | Traditional CLI | DNA Center |
|---------|----------------|------------|
| Configuration | SSH to each device | Centralized GUI/API |
| Consistency | Error-prone, manual | Templates, automated |
| Visibility | Per-device show commands | Single dashboard |
| Troubleshooting | Manual log analysis | AI-driven insights |
| Change speed | Hours/days | Minutes |
| Scale | Difficult | Handles thousands of devices |

### DNA Center Key Functions

**Intent-Based Networking (IBN):**
- Define *what* you want (intent), not *how* to configure it
- DNA Center translates intent into device-specific configurations

**SD-Access:**
- Automated campus fabric
- Macro/micro-segmentation with SGTs (Scalable Group Tags)
- Policy enforced by ISE (Identity Services Engine)

**Assurance:**
- 360-degree visibility
- AI/ML for anomaly detection
- Health scores for clients, devices, apps

### DNA Center API

DNA Center exposes a **REST API** for integration and automation.

```python
# Example: Python script using DNA Center REST API
import requests
import json

# DNA Center API endpoint
base_url = "https://dnac.company.com/api/v1"

# Authenticate
auth_response = requests.post(
    f"{base_url}/auth/token",
    auth=("admin", "password"),
    verify=False
)
token = auth_response.json()["Token"]

headers = {
    "X-Auth-Token": token,
    "Content-Type": "application/json"
}

# Get all network devices
devices = requests.get(
    f"{base_url}/network-device",
    headers=headers,
    verify=False
)

for device in devices.json()["response"]:
    print(f"Hostname: {device['hostname']}, IP: {device['managementIpAddress']}")
```

---

## 4. REST APIs

**REST (Representational State Transfer)** is an architectural style for web APIs. Uses HTTP methods to perform operations on resources.

### HTTP Methods (CRUD Operations)

| HTTP Method | Operation | Description |
|-------------|-----------|-------------|
| **GET** | Read | Retrieve information |
| **POST** | Create | Create a new resource |
| **PUT** | Update (replace) | Replace entire resource |
| **PATCH** | Update (partial) | Modify part of a resource |
| **DELETE** | Delete | Remove a resource |

```
REST API EXAMPLE — Managing VLANs on DNA Center:
────────────────────────────────────────────────────────────────

GET /api/v1/vlan                → Get all VLANs (Read)
POST /api/v1/vlan               → Create new VLAN (Create)
PUT /api/v1/vlan/10             → Replace VLAN 10 (Full update)
PATCH /api/v1/vlan/10           → Update VLAN 10 name (Partial update)
DELETE /api/v1/vlan/10          → Delete VLAN 10 (Delete)
```

### HTTP Status Codes

| Code | Category | Common Examples |
|------|----------|----------------|
| 2xx | Success | **200 OK**, **201 Created**, 204 No Content |
| 3xx | Redirect | 301 Moved Permanently |
| 4xx | Client Error | **400 Bad Request**, **401 Unauthorized**, **403 Forbidden**, **404 Not Found** |
| 5xx | Server Error | **500 Internal Server Error**, 503 Service Unavailable |

### REST API Authentication

| Method | Description |
|--------|-------------|
| **Basic Auth** | Username:password base64 encoded in header |
| **Token Auth** | Get token on login, include in subsequent requests |
| **API Key** | Static key in header or URL |
| **OAuth 2.0** | Token-based delegated authorization |

### REST API Request Structure

```
HTTP Request:
─────────────────────────────────────────────────────────────────
GET /api/v1/network-device HTTP/1.1
Host: dnac.company.com
X-Auth-Token: eyJhbGciOiJSUzI1...
Content-Type: application/json
Accept: application/json
                    ↑ Headers

HTTP Response:
─────────────────────────────────────────────────────────────────
HTTP/1.1 200 OK
Content-Type: application/json

{
  "response": [
    {
      "hostname": "R1",
      "managementIpAddress": "10.1.1.1",
      "platformId": "C1941",
      "softwareVersion": "15.6(3)M3"
    }
  ]
}
              ↑ JSON body
```

---

## 5. Data Formats: JSON, XML, YAML

### JSON (JavaScript Object Notation)

Most common format for REST APIs. Human-readable, lightweight.

```json
{
  "device": {
    "hostname": "R1",
    "interfaces": [
      {
        "name": "GigabitEthernet0/0",
        "ipAddress": "10.1.1.1",
        "subnetMask": "255.255.255.0",
        "status": "up",
        "enabled": true
      },
      {
        "name": "GigabitEthernet0/1",
        "ipAddress": "10.2.2.1",
        "subnetMask": "255.255.255.252",
        "status": "up",
        "enabled": true
      }
    ],
    "ospf": {
      "processId": 1,
      "routerId": "1.1.1.1",
      "area": 0
    }
  }
}
```

**JSON Data Types:**
- `string` — `"hello"` (in double quotes)
- `number` — `42` or `3.14`
- `boolean` — `true` or `false`
- `null` — `null`
- `array` — `[1, 2, 3]` or `["a", "b"]`
- `object` — `{"key": "value"}`

```
JSON STRUCTURE:
────────────────────────────────────────────────────────────────

{                        ← Object starts with {
  "key": "value",        ← String value
  "count": 3,            ← Number value
  "active": true,        ← Boolean value
  "nothing": null,       ← Null value
  "tags": [              ← Array starts with [
    "cisco",             ←   Array element
    "router"             ←   Array element
  ],                     ← Array ends with ]
  "nested": {            ← Nested object
    "level": 2           ←   Nested key-value
  }                      ← Nested object ends
}                        ← Object ends with }
```

### XML (Extensible Markup Language)

Used by NETCONF and some older APIs. More verbose than JSON.

```xml
<device>
  <hostname>R1</hostname>
  <interfaces>
    <interface>
      <name>GigabitEthernet0/0</name>
      <ipAddress>10.1.1.1</ipAddress>
      <subnetMask>255.255.255.0</subnetMask>
      <status>up</status>
    </interface>
  </interfaces>
  <ospf>
    <processId>1</processId>
    <routerId>1.1.1.1</routerId>
  </ospf>
</device>
```

### YAML (YAML Ain't Markup Language)

Commonly used for configuration files (Ansible playbooks, Docker Compose, Kubernetes).

```yaml
---
device:
  hostname: R1
  interfaces:
    - name: GigabitEthernet0/0
      ipAddress: 10.1.1.1
      subnetMask: 255.255.255.0
      status: up
      enabled: true
    - name: GigabitEthernet0/1
      ipAddress: 10.2.2.1
      subnetMask: 255.255.255.252
      status: up
      enabled: true
  ospf:
    processId: 1
    routerId: 1.1.1.1
    area: 0
```

**YAML key rules:**
- Uses **indentation** (spaces, not tabs!) for structure
- Lists start with `-`
- Key-value pairs: `key: value`
- Strings don't need quotes (unless they contain special characters)

| Feature | JSON | XML | YAML |
|---------|------|-----|------|
| Human readable | Good | Verbose | Best |
| Data size | Medium | Large | Small |
| Parsing | Simple | Complex | Simple |
| Used by | REST APIs | NETCONF | Ansible, configs |
| Comments | No | Yes | Yes (#) |

---

## 6. Configuration Management Tools

**Configuration management** tools automate the deployment and management of network/system configurations, reducing human error and enabling infrastructure-as-code.

### Traditional vs Automated Configuration

```
TRADITIONAL (Manual):
────────────────────────────────────────────────────────────────
Admin creates config → SSH to each device → Type commands → Verify

Problems:
  - Error-prone (typos, missed devices)
  - Time-consuming at scale
  - Hard to track changes
  - No version control

AUTOMATED (Config Management):
────────────────────────────────────────────────────────────────
Admin writes playbook/recipe → Tool pushes to ALL devices → Verify

Benefits:
  - Consistent configurations
  - Scalable to thousands of devices
  - Version-controlled (Git)
  - Idempotent (same result every run)
  - Auditable
```

### Ansible

**Ansible** — Agentless, push-based, uses SSH/NETCONF. Config written in **YAML** (playbooks). Most popular for network automation.

```
ANSIBLE ARCHITECTURE:
────────────────────────────────────────────────────────────────

[Control Node]
  └─ Inventory file (list of devices)
  └─ Playbooks (YAML automation scripts)
  └─ Roles (reusable task collections)
  └─ Templates (Jinja2)
          │ SSH/NETCONF (no agent needed)
          ↓
[Managed Nodes: Routers, Switches, Servers]
```

**Ansible Inventory Example:**
```yaml
# inventory.yml
all:
  children:
    routers:
      hosts:
        R1:
          ansible_host: 10.1.1.1
          ansible_user: admin
          ansible_password: password
        R2:
          ansible_host: 10.1.1.2
    switches:
      hosts:
        SW1:
          ansible_host: 10.1.2.1
```

**Ansible Playbook Example:**
```yaml
# configure-vlans.yml
---
- name: Configure VLANs on all switches
  hosts: switches
  gather_facts: no

  tasks:
    - name: Create VLAN 10
      ios_vlan:
        vlan_id: 10
        name: Sales
        state: present

    - name: Create VLAN 20
      ios_vlan:
        vlan_id: 20
        name: HR
        state: present

    - name: Configure access port Gi0/1 for VLAN 10
      ios_l2_interface:
        name: GigabitEthernet0/1
        mode: access
        access_vlan: 10

# Run with: ansible-playbook configure-vlans.yml -i inventory.yml
```

### Chef

**Chef** — Agent-based, pull-based. Config written in **Ruby** (recipes/cookbooks). Enterprise-grade, complex learning curve.

```
CHEF ARCHITECTURE:
────────────────────────────────────────────────────────────────

[Chef Workstation]
  └─ Cookbooks (Ruby recipes)
          │ Upload to Chef Server
[Chef Server]
  └─ Central repository of cookbooks + node info
          │ Agents PULL configs periodically
          ↓
[Chef Clients (Nodes)]
  └─ Chef agent installed, pulls and applies configs
```

**Chef cookbook example (Ruby):**
```ruby
# Recipe: configure_ospf.rb
template '/tmp/ospf_config.txt' do
  source 'ospf.txt.erb'
  variables(
    router_id: node['router_id'],
    area: node['ospf']['area']
  )
end

cisco_command_config 'configure_ospf' do
  command lazy { IO.read('/tmp/ospf_config.txt') }
end
```

### Puppet

**Puppet** — Agent-based (usually), pull-based. Config written in **Puppet DSL** (declarative). Mature, strong compliance features.

```
PUPPET ARCHITECTURE:
────────────────────────────────────────────────────────────────

[Puppet Master Server]
  └─ Manifests (desired state declarations)
  └─ Modules (reusable configs)
          │ HTTPS (certificates)
          ↓
[Puppet Agents (Nodes)]
  └─ Agent installed, pulls catalog every 30 min
  └─ Applies and enforces desired state
```

**Puppet manifest example:**
```puppet
# network_config.pp
class network_baseline {
  cisco_interface { 'GigabitEthernet0/0':
    ensure      => present,
    description => 'LAN Interface',
    ipv4_address => '10.1.1.1',
    ipv4_mask    => '255.255.255.0',
    shutdown     => false,
  }

  cisco_vlan { '10':
    ensure    => present,
    vlan_name => 'Sales',
  }
}
```

### Comparison

| Feature | Ansible | Chef | Puppet |
|---------|---------|------|--------|
| Agent required | No (agentless) | Yes | Yes (usually) |
| Push vs Pull | Push | Pull | Pull |
| Language | YAML (playbooks) | Ruby (recipes) | Puppet DSL |
| Learning curve | Low | High | Medium |
| Best for | Network, simple automation | Complex app configs | Enterprise compliance |
| Version | 2.x | 16+ | 7+ |

### Configuration Drift

**Configuration drift** — when device configuration diverges from the desired/baseline state over time due to manual changes, errors, or unauthorized changes.

```
CONFIGURATION DRIFT:
────────────────────────────────────────────────────────────────
Day 0:  Deploy standard config → [SW1, SW2, SW3] ← identical configs

Day 30: Admin manually changes SW2 for troubleshooting but forgets to revert
        [SW1] ← standard    [SW2] ← drifted    [SW3] ← standard

Problem: SW2 now has different security settings, VLANs, etc.
         Inconsistent behavior, potential security gap.

Solution: Config management tools detect and remediate drift automatically.
```

**How tools handle drift:**
- **Ansible** — Run playbooks regularly (idempotent — safe to re-apply)
- **Chef/Puppet** — Agents continuously enforce desired state (pull every 30 min)

### NETCONF and RESTCONF

**NETCONF** (RFC 6241)
- Uses SSH transport (TCP 830)
- XML data format
- Operations: `<get>`, `<get-config>`, `<edit-config>`, `<copy-config>`, `<delete-config>`, `<commit>`, `<lock>`

```xml
<!-- NETCONF get-config example -->
<rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">
  <get-config>
    <source>
      <running/>
    </source>
    <filter type="subtree">
      <interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces">
        <interface>
          <name>GigabitEthernet0/0</name>
        </interface>
      </interfaces>
    </filter>
  </get-config>
</rpc>
```

**RESTCONF** (RFC 8040)
- Uses HTTP/HTTPS transport
- JSON or XML data format
- Maps NETCONF operations to HTTP methods

```bash
# RESTCONF example — get interface config
curl -X GET \
  "https://router/restconf/data/ietf-interfaces:interfaces/interface=GigabitEthernet0%2F0" \
  -H "Accept: application/yang-data+json" \
  -u admin:password

# Response:
{
  "ietf-interfaces:interface": {
    "name": "GigabitEthernet0/0",
    "type": "iana-if-type:ethernetCsmacd",
    "enabled": true,
    "ietf-ip:ipv4": {
      "address": [
        {
          "ip": "10.1.1.1",
          "prefix-length": 24
        }
      ]
    }
  }
}
```

---

## Chapter 6 Summary

| Topic | Key Points |
|-------|-----------|
| Traditional vs SDN | Per-device CLI vs centralized controller |
| SDN planes | Control (decisions), Data (forwarding), Management (config) |
| SDN APIs | Northbound (apps↔controller), Southbound (controller↔devices) |
| DNA Center | Cisco's SDN controller, intent-based, AI/ML assurance |
| REST API | HTTP methods: GET/POST/PUT/PATCH/DELETE, JSON responses |
| HTTP status | 200=OK, 201=Created, 400=Bad Request, 401=Unauth, 404=Not Found |
| JSON | Key-value pairs, arrays, objects, no comments |
| Ansible | Agentless, YAML playbooks, SSH push |
| Chef | Agent-based, Ruby recipes, pull model |
| Puppet | Agent-based, Puppet DSL, pull model, compliance |
| Config drift | Deviation from desired state — config tools prevent/remediate |

---

*[← Chapter 5](05-security.md) | [Back to README →](../README.md)*
