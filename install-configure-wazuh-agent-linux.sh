#!/bin/bash
# Installation et configuration de l'agent Wazuh sur machine Linux cliente
# Auteurs : rto54 - 2025

WAZUH_MANAGER_IP="192.168.1.100"  # 🛠️ IP du serveur Wazuh à modifier
WAZUH_AGENT_NAME=$(hostname)

# === INSTALLATION AGENT ===
echo "[+] Installation de l'agent Wazuh..."
curl -sO https://packages.wazuh.com/4.7/wazuh-agent-4.7.3.deb
sudo dpkg -i wazuh-agent-4.7.3.deb

# === CONFIGURATION AGENT ===
sudo sed -i "s|<address>.*</address>|<address>${WAZUH_MANAGER_IP}</address>|" /var/ossec/etc/ossec.conf
sudo sed -i "s|<node_name>.*</node_name>|<node_name>${WAZUH_AGENT_NAME}</node_name>|" /var/ossec/etc/ossec.conf

# === ACTIVER SURVEILLANCE LOGS LOCAUX ===
sudo tee -a /var/ossec/etc/ossec.conf > /dev/null <<EOF

<localfile>
  <log_format>syslog</log_format>
  <location>/var/log/auth.log</location>
</localfile>
<localfile>
  <log_format>syslog</log_format>
  <location>/var/log/syslog</location>
</localfile>
EOF

# === ACTIVER SERVICE ===
sudo systemctl enable wazuh-agent
sudo systemctl restart wazuh-agent

echo "[✓] Agent Wazuh configuré et connecté à ${WAZUH_MANAGER_IP}"

# === CONFIGURATION EMAIL (OPTIONNEL) ===
EMAIL="admin@example.com"
SMTP_USER="your.email@gmail.com"
SMTP_PASS="app_password"
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT="587"

sudo tee /etc/s-nail.rc > /dev/null <<EOF
set smtp=smtp://${SMTP_SERVER}:${SMTP_PORT}
set smtp-use-starttls
set smtp-auth=login
set smtp-auth-user=${SMTP_USER}
set smtp-auth-password=${SMTP_PASS}
set from=${SMTP_USER}
set ssl-verify=ignore
EOF

echo "Alerte test depuis agent Linux $(hostname)" | s-nail -s "Wazuh Agent - Test Email" ${EMAIL}

# === TELEGRAM (OPTIONNEL) ===
TELEGRAM_TOKEN="your_telegram_bot_token"
TELEGRAM_CHAT_ID="your_chat_id"

if [[ -n "$TELEGRAM_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
  curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
       -d chat_id="$TELEGRAM_CHAT_ID" \
       -d text="✅ Agent Wazuh $(hostname) installé et connecté au manager."
fi
