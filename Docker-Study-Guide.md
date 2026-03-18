# Docker Study Guide
## From Zero to Security-Aware in One Read

---

## WHAT IS DOCKER?

Docker lets you package an application and everything it needs (code, libraries, settings) into a single portable unit called a **container**. That container runs the same way on any machine — your phone, a server, the cloud — no more "it works on my machine" problems.

**Real world analogy:**
- Old way = buying a house and moving all your furniture in (VM — full OS included, heavy)
- Docker way = shipping container on a cargo ship (lightweight, standardized, stackable)

---

## KEY CONCEPTS

### Image vs Container

| Image | Container |
|-------|-----------|
| Blueprint / recipe | The actual running thing |
| Stored on disk | Lives in memory while running |
| Like a class in code | Like an instance of that class |
| Built once, used many times | Created and destroyed frequently |

```
Image → run → Container
Image → run → Container
Image → run → Container
```

One image can spin up 100 identical containers.

---

### Dockerfile — How Images Are Built

A `Dockerfile` is a text file with step-by-step instructions to build an image:

```dockerfile
# Start from an existing base image (pulled from Docker Hub)
FROM ubuntu:22.04

# Run commands inside the image
RUN apt-get update && apt-get install -y python3

# Copy files from your computer into the image
COPY app.py /app/app.py

# Set the working directory
WORKDIR /app

# What runs when the container starts
CMD ["python3", "app.py"]
```

Build it:
```bash
docker build -t my-app .
```

Run it:
```bash
docker run my-app
```

---

### Docker Hub — The App Store for Images

Docker Hub (`hub.docker.com`) is a public registry of pre-built images.

```bash
# Pull an image from Docker Hub
docker pull nginx

# Run it immediately (pulls if not local)
docker run nginx

# Run with port mapping (host:container)
docker run -p 8080:80 nginx
# Now visit localhost:8080 to see nginx
```

Popular official images: `ubuntu`, `python`, `node`, `mysql`, `redis`, `nginx`

---

## ESSENTIAL COMMANDS

```bash
# IMAGES
docker images                    # list local images
docker pull ubuntu               # download image
docker build -t myapp .          # build from Dockerfile
docker rmi myapp                 # delete image

# CONTAINERS
docker run ubuntu                # create + start container
docker run -d nginx              # run in background (detached)
docker run -it ubuntu bash       # run interactively with terminal
docker run -p 8080:80 nginx      # map port 8080 on host to 80 in container
docker run -v /host/path:/container/path nginx  # mount a volume

docker ps                        # list running containers
docker ps -a                     # list ALL containers (including stopped)
docker stop <container_id>       # stop a container
docker rm <container_id>         # delete a container
docker logs <container_id>       # view container output

# EXEC INTO RUNNING CONTAINER (like SSH)
docker exec -it <container_id> bash

# CLEANUP
docker system prune              # remove all stopped containers + unused images
```

---

## DOCKER COMPOSE — Running Multiple Containers

Real apps have multiple services (web server + database + cache). Docker Compose manages them together.

`docker-compose.yml`:
```yaml
version: '3'
services:
  web:
    image: nginx
    ports:
      - "8080:80"

  database:
    image: postgres
    environment:
      POSTGRES_PASSWORD: secret

  cache:
    image: redis
```

```bash
docker-compose up      # start everything
docker-compose down    # stop everything
docker-compose logs    # view all logs
```

---

## NETWORKING IN DOCKER

Containers are isolated by default — they can't talk to each other unless you connect them.

```bash
# Create a network
docker network create mynetwork

# Run containers on same network (they can talk by name)
docker run --network mynetwork --name web nginx
docker run --network mynetwork --name db postgres

# Isolate completely (no network at all)
docker run --network none myapp
```

**Port mapping:**
```bash
# -p hostPort:containerPort
docker run -p 3000:80 nginx
# Your computer's port 3000 → container's port 80
```

---

## VOLUMES — Persistent Storage

Containers are ephemeral — when they die, data dies too. Volumes fix that.

```bash
# Mount a host directory into container
docker run -v /home/justin/data:/app/data myapp

# Named volume (Docker manages it)
docker volume create mydata
docker run -v mydata:/app/data myapp

# List volumes
docker volume ls
```

---

## SECURITY — The Part That Matters for Your Job

### 1. Never Run as Root
```dockerfile
# BAD - runs as root by default
FROM ubuntu
CMD ["myapp"]

# GOOD - create and use non-root user
FROM ubuntu
RUN useradd -m appuser
USER appuser
CMD ["myapp"]
```

### 2. Image Scanning — Find Vulnerabilities Before Deployment

**Trivy** (most popular free scanner):
```bash
# Install trivy
apt install trivy

# Scan an image
trivy image nginx

# Output shows CVEs by severity
# CRITICAL, HIGH, MEDIUM, LOW
```

**Docker Scout** (built into Docker):
```bash
docker scout cves nginx
```

Always scan before pushing to production. A single base image can have 50+ CVEs.

### 3. Read-Only File System
```bash
# Container can't write to its own filesystem
docker run --read-only nginx

# Allow writes only to specific paths
docker run --read-only --tmpfs /tmp nginx
```

### 4. Limit Resources
```bash
# Limit CPU and memory (prevents resource exhaustion attacks)
docker run --memory="256m" --cpus="0.5" myapp
```

### 5. Don't Store Secrets in Images
```dockerfile
# BAD — secret baked into image, visible to anyone
ENV DB_PASSWORD=supersecret123

# GOOD — pass at runtime
docker run -e DB_PASSWORD=$DB_PASSWORD myapp

# BETTER — use Docker secrets or a secrets manager (Vault, AWS Secrets Manager)
```

### 6. Use Minimal Base Images
```dockerfile
# BAD — full Ubuntu = large attack surface
FROM ubuntu:22.04

# GOOD — Alpine Linux = tiny, minimal packages
FROM alpine:3.18

# BEST for compiled apps — literally nothing but your binary
FROM scratch
```

Smaller image = fewer packages = fewer CVEs.

### 7. Container Escape Attacks
The biggest container security concern — attacker breaks out of container to reach the host OS.

**Common causes:**
- Running as root inside container
- `--privileged` flag (gives container full host access — never use in prod)
- Mounting sensitive host paths (`-v /:/host`)
- Kernel vulnerabilities

**Prevention:**
- Never use `--privileged`
- Never mount `/` or `/etc` from host
- Keep Docker and host kernel patched
- Use **seccomp profiles** to limit syscalls
- Use **AppArmor/SELinux** for mandatory access control

---

## KUBERNETES (K8S) — Docker at Scale

Once you have dozens or hundreds of containers, you need something to manage them. That's Kubernetes.

**Docker = runs one container**
**Kubernetes = manages thousands of containers across many servers**

### Key K8s Concepts

| Term | What It Is |
|------|-----------|
| **Pod** | Smallest unit — one or more containers running together |
| **Node** | A server (physical or VM) that runs pods |
| **Cluster** | A group of nodes managed by K8s |
| **Deployment** | Defines how many copies of a pod to run |
| **Service** | Exposes pods to network traffic |
| **Namespace** | Virtual cluster for isolation (like folders) |

### K8s Security Concepts

**RBAC (Role-Based Access Control):**
```yaml
# Give a pod read-only access to secrets in one namespace only
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
```

**Network Policies — block pod-to-pod traffic:**
```yaml
# Only allow traffic from pods with label "app: frontend"
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
spec:
  podSelector:
    matchLabels:
      app: database
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
```

**Pod Security — prevent privileged containers:**
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
```

---

## DEVSECOPS CONNECTION

Docker fits into CI/CD security like this:

```
Code commit
    ↓
[SAST scan - check source code]
    ↓
Docker build
    ↓
[Trivy/Scout scan - check image for CVEs]
    ↓
Push to registry
    ↓
[Policy check - does image meet security standards?]
    ↓
Deploy to Kubernetes
    ↓
[Runtime monitoring - Falco, Sysdig]
```

Tools to know by name:
- **Trivy** — image scanning
- **Falco** — runtime threat detection in K8s
- **OPA (Open Policy Agent)** — policy enforcement
- **Snyk** — dependency + container scanning
- **Harbor** — private container registry with built-in scanning

---

## INTERVIEW CHEAT SHEET

**"What's the difference between a container and a VM?"**
> "A VM includes a full OS — it's heavy and slow to start. A container shares the host OS kernel and only packages the app and its dependencies — it's lightweight, starts in seconds, and is much more portable."

**"How do you secure a container?"**
> "Run as non-root, use minimal base images, scan images for CVEs with Trivy, never use --privileged, don't store secrets in the image, set read-only filesystems, and limit CPU/memory."

**"What is container escape?"**
> "It's when an attacker breaks out of the container sandbox and gains access to the host OS. Prevention includes avoiding privileged mode, patching the kernel, and using security profiles like seccomp and AppArmor."

**"What's Kubernetes used for?"**
> "Orchestrating containers at scale — automating deployment, scaling, and management of containerized applications across a cluster of servers. It adds RBAC, network policies, and pod security on top of Docker."

---

## QUICK PRACTICE (Do This on Your Phone/PC)

```bash
# 1. Pull and run your first container
docker run hello-world

# 2. Run an interactive Ubuntu container
docker run -it ubuntu bash
# Now you're inside the container! Try: ls, whoami, exit

# 3. Run nginx web server
docker run -d -p 8080:80 nginx
# Open browser: localhost:8080

# 4. Scan an image for vulnerabilities
docker pull python:3.9
trivy image python:3.9
```

---

*Part of the DeNOVO Cybersecurity Specialist 1 Job Prep Series*
*Justin Youngs | Jyoungs42433@gmail.com*
