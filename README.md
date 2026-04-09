# Portfolio — Azure Static Web Apps

A personal cloud engineering portfolio. Pure HTML + CSS + JS.
Zero framework, zero build step, zero cost to deploy.

## Deploy in 3 Commands

```bash
# 1. Install Azure CLI (if not already)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# 2. Login (use --use-device-code in WSL)
az login --use-device-code

# 3. Run deploy script
chmod +x deploy-azure.sh
./deploy-azure.sh
```

Done. Your site is live at `https://<random-name>.azurestaticapps.net`

---

## Manual Step-by-Step (to understand each command)

```bash
# Step 1 — Create Resource Group
az group create \
  --name portfolio-rg \
  --location centralus

# Step 2 — Create Static Web App (FREE tier, no card risk)
az staticwebapp create \
  --name my-portfolio-2026 \
  --resource-group portfolio-rg \
  --location centralus \
  --sku Free

# Step 3 — Get deployment token
az staticwebapp secrets list \
  --name my-portfolio-2026 \
  --resource-group portfolio-rg \
  --query "properties.apiKey" \
  --output tsv

# Step 4 — Deploy files using SWA CLI
npx @azure/static-web-apps-cli deploy . \
  --deployment-token <token-from-step-3> \
  --env production

# Step 5 — Get your live URL
az staticwebapp show \
  --name my-portfolio-2026 \
  --resource-group portfolio-rg \
  --query defaultHostname \
  --output tsv
```

---

## What Azure Static Web Apps Gives You FREE

| Feature                  | Free Tier Value         |
|--------------------------|-------------------------|
| Bandwidth                | 100 GB / month          |
| Storage                  | 0.5 GB                  |
| Custom domains           | 2 per app               |
| SSL certificate          | Auto-provisioned, free  |
| Global CDN               | ✅ Yes                  |
| Staging environments     | 3                       |
| GitHub Actions CI/CD     | ✅ Built-in             |
| Cost                     | $0.00                   |

---

## Add a Custom Domain (Optional)

```bash
# After deploying, point your domain's CNAME to the Azure URL
az staticwebapp hostname set \
  --name my-portfolio-2026 \
  --resource-group portfolio-rg \
  --hostname yourdomain.com
```

---

## Update the Site

Just re-run the deploy command — SWA CLI diffs and uploads only changed files:
```bash
./deploy-azure.sh
```

---

## Cleanup

```bash
# Delete everything — no ongoing charges
az group delete --name portfolio-rg --yes --no-wait
```

---

## Customise the Portfolio

Edit `index.html` directly — find these sections and update:

| Section      | What to change                            |
|--------------|-------------------------------------------|
| Hero         | Name, tagline, status text                |
| Stats bar    | Years of experience, platforms, degree    |
| Stack grid   | Your actual tech stack                    |
| Projects     | Your real project titles and descriptions |
| Timeline     | Your actual work history                  |
| Certifications | Your certs and their status            |
| Contact      | Your real email, LinkedIn, GitHub URLs    |

## Files

```
azure-static-app/
├── index.html                  ← Entire site (single file)
├── staticwebapp.config.json    ← Azure routing + security headers
├── deploy-azure.sh             ← One-click deploy script
└── README.md                   ← This file
```
