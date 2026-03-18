# Docker Advanced & Hands-On Study Guide
## Beyond the Basics — Real World Docker for Security Pros

---

## PICKING UP WHERE WE LEFT OFF

You know what images, containers, Dockerfiles, and basic security are. This guide goes deeper:
- Multi-stage builds
- Real vulnerability scanning workflows
- Docker in CI/CD pipelines
- Hands-on labs you can run right now
- Advanced Kubernetes security
- Interview-level depth

---

## MULTI-STAGE BUILDS — Smaller, Safer Images

The problem: if you build code inside a container, your final image contains compilers, build tools, and source code — massive attack surface.

**Solution: multi-stage builds** — build in one stage, copy only the output to a clean final image.

```dockerfile
# Stage 1: Build
FROM golang:1.21 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp .

# Stage 2: Run (tiny final image — no Go compiler included)
FROM alpine:3.18
WORKDIR /app
COPY --from=builder /app/myapp .
USER nonroot
CMD ["./myapp"]
```

**Result:** Image goes from ~800MB → ~10MB. Fewer packages = fewer CVEs.

---

## REAL VULNERABILITY SCANNING WORKFLOW

### Step 1: Install Trivy
```bash
# Ubuntu/Debian
apt install trivy

# Or via script
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
```

### Step 2: Scan an Image
```bash
# Basic scan
trivy image nginx:latest

# Only show CRITICAL and HIGH
trivy image --severity CRITICAL,HIGH nginx:latest

# Output as JSON for automation
trivy image --format json --output results.json nginx:latest

# Scan your own built image
docker build -t myapp .
trivy image myapp
```

### Step 3: Read the Output
```
nginx:latest (debian 12.4)
Total: 142 (CRITICAL: 2, HIGH: 28, MEDIUM: 67, LOW: 45)

┌──────────────────┬────────────────┬──────────┬──────────────────────┐
│ Library          │ Vulnerability  │ Severity │ Fixed Version        │
├──────────────────┼────────────────┼──────────┼──────────────────────┤
│ openssl          │ CVE-2023-xxxx  │ CRITICAL │ 3.0.12               │
│ libssl           │ CVE-2023-xxxx  │ HIGH     │ 3.0.12               │
└──────────────────┴────────────────┴──────────┴──────────────────────┘
```

### Step 4: Fix It
```dockerfile
# Pin to a specific patched version
FROM nginx:1.25.3-alpine

# Or use a digest (immutable — never changes even if tag is overwritten)
FROM nginx@sha256:a5127daff3d6f4606be3100a252419bfa84fd6ee5cd74d0feaca1a5068f97dcf
```

### Automate in CI/CD
```yaml
# GitHub Actions example
- name: Scan image
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: myapp:latest
    severity: CRITICAL,HIGH
    exit-code: 1  # Fail the pipeline if vulns found
```

---

## DOCKER NETWORKING — DEEP DIVE

### Network Types
```bash
# Bridge (default) — containers on same host can communicate
docker network create --driver bridge mynet

# Host — container shares host network stack (no isolation!)
docker run --network host nginx

# None — completely isolated
docker run --network none myapp

# Overlay — multi-host networking (used in Docker Swarm/K8s)
docker network create --driver overlay swarmnet
```

### DNS Between Containers
```bash
# Create network
docker network create appnet

# Run containers — they can reach each other by NAME
docker run -d --network appnet --name web nginx
docker run -d --network appnet --name db postgres

# 'web' container can reach 'db' at hostname 'db'
docker exec web curl http://db:5432
```

### Security: Isolate Services
```bash
# Frontend talks to backend but NOT directly to database
docker network create frontend-net
docker network create backend-net

docker run --network frontend-net --name web nginx
docker run --network frontend-net --network backend-net --name api myapi
docker run --network backend-net --name db postgres

# web → api ✅  |  api → db ✅  |  web → db ❌
```

---

## VOLUMES — DEEP DIVE

```bash
# Bind mount (host path → container)
docker run -v /home/justin/data:/app/data myapp

# Named volume (Docker manages location)
docker volume create appdata
docker run -v appdata:/app/data myapp

# Read-only mount (container can READ but not WRITE)
docker run -v /host/config:/app/config:ro myapp

# tmpfs (in-memory only — nothing written to disk)
docker run --tmpfs /tmp myapp
```

### Backup a Volume
```bash
# Tar the volume contents to host
docker run --rm \
  -v appdata:/source \
  -v $(pwd):/backup \
  alpine tar czf /backup/appdata-backup.tar.gz -C /source .
```

---

## SECRETS MANAGEMENT — THE RIGHT WAY

### Bad (Never Do This)
```dockerfile
ENV DB_PASSWORD=supersecret  # baked into image forever
```

### Okay (Runtime env var)
```bash
docker run -e DB_PASSWORD=$DB_PASSWORD myapp
```

### Better (Docker Secrets — Swarm mode)
```bash
# Create secret
echo "supersecret" | docker secret create db_password -

# Use in service
docker service create \
  --secret db_password \
  --name myapp \
  myimage
# Secret available at /run/secrets/db_password inside container
```

### Best (External Secrets Manager)
- **HashiCorp Vault** — enterprise standard
- **AWS Secrets Manager** — if on AWS
- **Azure Key Vault** — if on Azure
- App fetches secret at runtime, never stored in image or env

---

## HEALTH CHECKS

Tell Docker how to know if your container is actually healthy:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost/health || exit 1
```

```bash
# See health status
docker ps
# STATUS column shows: healthy, unhealthy, starting

docker inspect --format='{{.State.Health.Status}}' mycontainer
```

---

## RESOURCE LIMITS — PREVENT ABUSE

```bash
# Memory limit (container killed if exceeded)
docker run --memory="512m" myapp

# CPU limit (0.5 = half a core)
docker run --cpus="0.5" myapp

# Both together
docker run --memory="256m" --cpus="0.25" myapp

# See current usage
docker stats
```

---

## LOGGING

```bash
# Default: view logs
docker logs mycontainer
docker logs -f mycontainer        # follow (like tail -f)
docker logs --tail 50 mycontainer # last 50 lines

# Log drivers (send logs elsewhere)
docker run --log-driver=syslog myapp      # to syslog
docker run --log-driver=json-file myapp   # default
docker run --log-driver=splunk \
  --log-opt splunk-token=TOKEN \
  --log-opt splunk-url=https://splunk:8088 \
  myapp
```

---

## DOCKER COMPOSE — ADVANCED

```yaml
version: '3.8'

services:
  web:
    build: ./web
    ports:
      - "80:80"
    depends_on:
      db:
        condition: service_healthy
    networks:
      - frontend
    environment:
      - NODE_ENV=production
    secrets:
      - db_password
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.5'
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:15-alpine
    volumes:
      - dbdata:/var/lib/postgresql/data
    networks:
      - backend
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

networks:
  frontend:
  backend:

volumes:
  dbdata:

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

---

## KUBERNETES SECURITY — ADVANCED

### Pod Security Context (Full Example)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault      # restrict syscalls

  containers:
  - name: app
    image: myapp:latest
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
          - ALL                 # drop ALL linux capabilities
        add:
          - NET_BIND_SERVICE    # only add back what's needed
    resources:
      limits:
        memory: "256Mi"
        cpu: "500m"
    volumeMounts:
    - mountPath: /tmp
      name: tmp-volume

  volumes:
  - name: tmp-volume
    emptyDir: {}
```

### RBAC — Least Privilege
```yaml
# ServiceAccount for the pod
apiVersion: v1
kind: ServiceAccount
metadata:
  name: myapp-sa
  namespace: production

---
# Role: only read configmaps in production namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: configmap-reader
  namespace: production
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list"]

---
# Bind role to serviceaccount
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-configmaps
  namespace: production
subjects:
- kind: ServiceAccount
  name: myapp-sa
roleRef:
  kind: Role
  name: configmap-reader
  apiGroup: rbac.authorization.k8s.io
```

### Network Policies — Deny All, Allow Specific
```yaml
# Start with deny-all
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress

---
# Then explicitly allow what's needed
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web-to-api
spec:
  podSelector:
    matchLabels:
      app: api
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: web
    ports:
    - port: 8080
```

---

## HANDS-ON LABS

### Lab 1: Build and Scan a Vulnerable Image
```bash
# Pull a known-vulnerable image
docker pull python:3.8

# Scan it
trivy image python:3.8

# Compare to newer version
trivy image python:3.12-alpine

# See the difference in CVE count
```

### Lab 2: Container Escape Demo (Safe)
```bash
# See what happens with --privileged (DON'T do in prod)
docker run --privileged -it alpine sh

# Inside container — you can see host devices
ls /dev
# You have nearly full host access — this is the danger
exit
```

### Lab 3: Network Isolation
```bash
# Create two isolated networks
docker network create net-a
docker network create net-b

# Run containers on separate networks
docker run -d --network net-a --name container-a alpine sleep 3600
docker run -d --network net-b --name container-b alpine sleep 3600

# Try to ping across networks (should FAIL)
docker exec container-a ping container-b
# ping: bad address 'container-b' — isolated!
```

### Lab 4: Secrets the Right Way
```bash
# Create a secret file (not in image, not in env)
echo "my-db-password" > /tmp/db_secret.txt

# Mount as read-only file in container
docker run -v /tmp/db_secret.txt:/run/secrets/db_password:ro \
  alpine cat /run/secrets/db_password
```

---

## MOCK INTERVIEW Q&A

**Q: What's a multi-stage build and why does it matter for security?**
> "Multi-stage builds let you separate the build environment from the runtime environment. You compile or build in a full image with all the tools, then copy only the binary or artifact into a minimal final image. This means your production container doesn't contain compilers, source code, or build tools — dramatically reducing the attack surface and CVE count."

**Q: How would you handle secrets in a containerized environment?**
> "I'd never bake secrets into images or use ENV for sensitive values. For Docker, I'd use Docker Secrets or mount secret files at runtime. In Kubernetes, I'd use K8s Secrets combined with an external manager like HashiCorp Vault or AWS Secrets Manager, where the app fetches credentials at startup rather than having them stored anywhere persistent."

**Q: Walk me through how you'd secure a Kubernetes deployment.**
> "I'd start with a deny-all NetworkPolicy and explicitly allow only required traffic. I'd configure pod security contexts — non-root user, read-only filesystem, drop all Linux capabilities and add back only what's needed, disable privilege escalation, and apply a seccomp profile. I'd use RBAC with a dedicated ServiceAccount that has minimal permissions. I'd scan the image with Trivy before deployment, set resource limits, and use runtime monitoring like Falco to detect anomalous behavior."

**Q: What is Falco and why would you use it?**
> "Falco is a runtime security tool for Kubernetes that monitors system calls and container behavior in real time. It detects things like a shell being spawned inside a container, unexpected network connections, or file writes to sensitive paths — behaviors that indicate a breach or container escape attempt. It's essentially an IDS for your container environment."

---

## RESOURCES

- **Play with Docker** — labs.play-with-docker.com (free browser-based Docker)
- **Killer.sh** — K8s exam simulator
- **TryHackMe** — "Container Security" room
- **CIS Docker Benchmark** — cisecurity.org (hardening checklist)
- **Trivy docs** — aquasecurity.github.io/trivy

## CERT ROADMAP
1. **Docker Certified Associate (DCA)** — validates Docker skills
2. **CKA** (Certified Kubernetes Administrator) — the gold standard
3. **CKS** (Certified Kubernetes Security Specialist) — security-focused, highly desired in IC/DoD

---
*Part of the DeNOVO Cybersecurity Specialist 1 Job Prep Series*
