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
