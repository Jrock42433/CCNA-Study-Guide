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
