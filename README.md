
# 📝 Todo App — Flask + GitHub Actions CI/CD + EKS

This project is a **Flask-based Todo application** containerized with Docker, deployed to **AWS EKS**, and powered by a **GitHub Actions CI/CD pipeline**. It includes **Terraform** to provision cloud infrastructure and deploys directly to the Kubernetes cluster.

---

## 📁 Project Structure

```text
.
├── .github/workflows/
│   └── ci-cd.yml              # GitHub Actions pipeline (CI/CD)
├── k8s/
│   ├── deployment.yaml        # Kubernetes Deployment for Flask app
│   └── service.yaml           # Kubernetes Service for the app
├── static/
│   └── style.css              # CSS styles for the web UI
├── templates/
│   └── index.html             # HTML template (Jinja2) for the app
├── terraform/
│   ├── eks-cluster.tf         # Provisions EKS cluster
│   ├── main.tf                # Terraform entry point
│   ├── variables.tf           # Input variables
│   └── outputs.tf             # Terraform outputs
├── app.py                     # Flask application logic
├── Dockerfile                 # Docker configuration
├── requirements.txt           # Python dependencies
└── README.md                  # 📄 (You're here!)
```

---

## 🚀 Features

- 🧩 **Flask Web App** – Simple task list with add/delete functionality
- 🐳 **Dockerized** – Easily build and run in any environment
- ☸️ **Kubernetes Ready** – K8s manifests included
- ⚙️ **GitHub Actions CI/CD** – Automated build + deploy pipeline
- 🌩️ **Terraform for AWS EKS** – Infrastructure as Code

---

## 🔄 GitHub Actions CI/CD Pipeline (Step-by-Step)

The pipeline is defined in `.github/workflows/ci-cd.yml` and runs on every push to the `main` branch.

### 📋 Steps Overview

1. **Checkout the code**
2. **Set up Docker build environment**
3. **Login to DockerHub**
4. **Build and push Docker image to DockerHub**
5. **Configure AWS credentials**
6. **Install Terraform**
7. **Initialize Terraform**
8. **Provision EKS infrastructure via Terraform**
9. **Install `kubectl`**
10. **Update kubeconfig to connect to EKS**
11. **Install Helm**
12. **Create/update Bugsnag secret in Kubernetes**
13. **Apply Kubernetes manifests (Deployment + Service)**
14. **Wait for rollout to complete**
15. **Check deployment status**
16. **List running pods**
17. **Describe the Deployment**
18. **View logs of the running pod**
19. **(Optional) Install Datadog via Helm**
20. **Verify Datadog agent status (pods & Helm)**
21. **Inject environment variables into Deployment**
22. **Wait and display LoadBalancer external IP**

> ✅ This full pipeline ensures zero-touch provisioning + deployment of the app to EKS.

---

## 🔐 Required GitHub Secrets

| Secret Name             | Description                                |
|-------------------------|--------------------------------------------|
| `DOCKER_USERNAME`       | Docker Hub username                        |
| `DOCKER_PASSWORD`       | Docker Hub password/token                  |
| `AWS_ACCESS_KEY_ID`     | AWS access key for Terraform/AWS CLI       |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key                             |
| `AWS_REGION`            | AWS region (e.g. `us-east-1`)              |
| `DATADOG_API_KEY`       | Datadog API Key (if using Datadog)         |
| `BUGSNAG_API_KEY`       | Bugsnag API Key for error monitoring       |

---

## 🐍 Flask App Overview

File: `app.py`

- Routes:
  - `/` – List all tasks
  - `/add` – Add a new task
  - `/delete/<id>` – Delete a task by ID
- Tasks are stored in an **in-memory list** (no DB)

---

## 🐳 Docker Setup

**Dockerfile:**

- Uses `python:3.10-slim`
- Copies application source
- Installs dependencies from `requirements.txt`
- Exposes port `5000` for Flask

---

## ☸️ Kubernetes Deployment

Located in `k8s/`:

- **`deployment.yaml`** – Deploys app with Docker image from Docker Hub
- **`service.yaml`** – Exposes app as a LoadBalancer service (external IP)

---

## 📦 Terraform Infrastructure

Located in `terraform/`:

- Provisions:
  - AWS EKS Cluster
  - IAM Roles
  - Node Groups
- Outputs a `kubeconfig` to connect via `kubectl`
- Can also deploy Helm charts (if configured)

---

## ✅ Usage Workflow

1. **Push Code to GitHub**
2. **GitHub Actions Pipeline Executes:**
   - Checks out code
   - Builds Docker image and pushes to Docker Hub
   - Provisions AWS EKS using Terraform
   - Connects to EKS via kubeconfig
   - Applies Kubernetes manifests (Deployment + Service)
   - Optionally installs Datadog + Helm charts
   - Injects environment secrets
   - Outputs external LoadBalancer IP
3. **Access the App in Browser**
   - Wait for the external IP from the pipeline logs
   - Open `http://<external-ip>` in your browser

---

## 🔮 Future Enhancements

- Add persistent database (PostgreSQL, DynamoDB, etc.)
- Integrate test framework (pytest) + add test job to pipeline
- Add custom domain and HTTPS using Ingress + Cert Manager
- Replace in-memory tasks with cloud-native storage
- Add logging/metrics dashboards (Grafana, Prometheus)

---

## 📜 License

MIT License