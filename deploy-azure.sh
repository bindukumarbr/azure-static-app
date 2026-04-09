#!/bin/bash
# deploy-azure.sh
# Deploy this static site to Azure Static Web Apps (FREE tier)
# Run from the azure-static-app/ directory

set -e

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   Azure Static Web Apps — Deploy Script          ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# ── Config — edit these ────────────────────────────────────
RG="portfolio-rg"
LOCATION="centralus"        # Free tier available in all regions
APP_NAME="bindukumar-portfolio-$(date +%s)"   # Must be globally unique

# ── 1. Check Azure CLI ─────────────────────────────────────
command -v az >/dev/null || {
  echo "❌ Azure CLI not found."
  echo "   Install: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
  exit 1
}
echo "✅ Azure CLI found"

# ── 2. Login ───────────────────────────────────────────────
echo ""
echo "▶ Checking Azure login..."
az account show >/dev/null 2>&1 || {
  echo "Not logged in. Running az login..."
  az login --use-device-code
}
echo "✅ Logged in as: $(az account show --query user.name -o tsv)"

# ── 3. Create Resource Group ───────────────────────────────
echo ""
echo "▶ Creating Resource Group: $RG..."
az group create --name $RG --location $LOCATION --output none
echo "✅ Resource Group ready"

# ── 4. Create Static Web App (FREE tier) ──────────────────
echo ""
echo "▶ Creating Static Web App: $APP_NAME (FREE tier)..."
RESULT=$(az staticwebapp create \
  --name $APP_NAME \
  --resource-group $RG \
  --location $LOCATION \
  --sku Free \
  --output json)

# Get the deployment token
DEPLOY_TOKEN=$(az staticwebapp secrets list \
  --name $APP_NAME \
  --resource-group $RG \
  --query "properties.apiKey" \
  --output tsv)

# Get the default hostname
HOSTNAME=$(echo $RESULT | python3 -c "import sys,json; print(json.load(sys.stdin)['properties']['defaultHostname'])" 2>/dev/null || \
  az staticwebapp show --name $APP_NAME --resource-group $RG --query defaultHostname -o tsv)

echo "✅ Static Web App created"
echo "   URL: https://$HOSTNAME"

# ── 5. Deploy using SWA CLI ───────────────────────────────
echo ""
echo "▶ Installing SWA CLI if needed..."
npx --yes @azure/static-web-apps-cli --version >/dev/null 2>&1 || true

echo ""
echo "▶ Deploying site files..."
npx @azure/static-web-apps-cli deploy . \
  --deployment-token $DEPLOY_TOKEN \
  --env production \
  --no-use-keychain

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║              ✅ DEPLOYMENT COMPLETE               ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║                                                  ║"
echo "║  🌐 URL: https://$HOSTNAME"
echo "║                                                  ║"
echo "║  Free tier includes:                             ║"
echo "║  ✓ Global CDN distribution                       ║"
echo "║  ✓ Free SSL/HTTPS certificate                    ║"
echo "║  ✓ Custom domain support                         ║"
echo "║  ✓ 100GB bandwidth/month                         ║"
echo "║  ✓ No credit card charge                         ║"
echo "╚══════════════════════════════════════════════════╝"
