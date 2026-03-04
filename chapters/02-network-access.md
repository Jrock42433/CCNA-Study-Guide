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
