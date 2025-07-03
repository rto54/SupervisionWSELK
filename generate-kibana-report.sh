#!/bin/bash
# Script : Générer un rapport PDF depuis Kibana et l’envoyer par mail
# Auteur : rto54 - 2025

KIBANA_HOST="http://localhost:5601"
DASHBOARD_ID="supervision-complete"
USER="elastic"
PASS="changeme"

OUTPUT="/tmp/kibana-report.pdf"
EMAIL_TO="admin@example.com"
EMAIL_FROM="your.email@gmail.com"
SMTP_USER="your.email@gmail.com"
SMTP_PASS="your_app_password"
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT="587"

# Génération du PDF via API Kibana
echo "[+] Génération du PDF depuis le dashboard Kibana..."
curl -s -u $USER:$PASS -X POST "$KIBANA_HOST/api/reporting/generate/dashboard/$DASHBOARD_ID" \
  -H 'kbn-xsrf: true' > /tmp/kibana_report_request.json

REPORT_PATH=$(jq -r .path /tmp/kibana_report_request.json)
if [[ "$REPORT_PATH" == "null" ]]; then
  echo "[-] Échec de génération du rapport."
  exit 1
fi

echo "[+] Récupération du rapport PDF..."
curl -s -u $USER:$PASS -o "$OUTPUT" "$KIBANA_HOST$REPORT_PATH"

# Configuration s-nail temporaire
cat <<EOF > ~/.mailrc
set smtp=smtp://${SMTP_SERVER}:${SMTP_PORT}
set smtp-use-starttls
set smtp-auth=login
set smtp-auth-user=${SMTP_USER}
set smtp-auth-password=${SMTP_PASS}
set from=${SMTP_USER}
set ssl-verify=ignore
EOF

# Envoi du mail avec pièce jointe
echo "Rapport de supervision Suricata + Wazuh généré automatiquement." \
  | mailx -s "🛡️ Rapport Wazuh/Suricata" -a "$OUTPUT" "$EMAIL_TO"

echo "[✓] Rapport envoyé à : $EMAIL_TO"
