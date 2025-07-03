#!/bin/bash
# Script d'installation ELK + Filebeat pour supervision Suricata
# Debian 12 | Auteur : rto54 - 2025

set -e

echo "[+] Mise à jour du système..."
apt update && apt upgrade -y

echo "[+] Installation de Suricata..."
apt install -y suricata apt-transport-https curl gnupg lsb-release unzip

echo "[+] Installation d'Elasticsearch, Kibana, Filebeat..."

# Ajout du repo Elastic
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elastic.gpg
echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main"   | tee /etc/apt/sources.list.d/elastic-8.x.list

apt update
apt install -y elasticsearch kibana filebeat

echo "[+] Configuration Elasticsearch..."
sed -i 's/#network.host:.*/network.host: localhost/' /etc/elasticsearch/elasticsearch.yml
systemctl daemon-reexec
systemctl enable elasticsearch --now

sleep 15

echo "[+] Configuration Kibana..."
sed -i 's/#server.host:.*/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml
sed -i 's/#elasticsearch.hosts:.*/elasticsearch.hosts: ["http:\/\/localhost:9200"]/' /etc/kibana/kibana.yml
systemctl enable kibana --now

echo "[+] Configuration Filebeat pour Suricata..."
filebeat modules enable suricata

cat <<EOF >> /etc/filebeat/filebeat.yml

filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/suricata/eve.json
  json.keys_under_root: true
  json.add_error_key: true
  fields:
    service: suricata

output.elasticsearch:
  hosts: ["http://localhost:9200"]
EOF

echo "[+] Setup des dashboards..."
filebeat setup --index-management -E setup.kibana.host=localhost:5601
filebeat setup --dashboards
systemctl enable filebeat --now

echo "[✓] Installation complète terminée !"
echo "Accède à Kibana via : http://<IP>:5601"
