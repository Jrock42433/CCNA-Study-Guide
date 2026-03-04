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
