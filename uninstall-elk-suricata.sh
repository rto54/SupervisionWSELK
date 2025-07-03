#!/bin/bash
# Script de désinstallation complète d'ELK stack + Filebeat + Suricata
# Auteur : rto54

echo "[!] Ce script va supprimer Elasticsearch, Kibana, Filebeat, Suricata et leurs configurations."
read -p "Continuer ? (y/n): " confirm

if [[ "$confirm" != "y" ]]; then
    echo "Annulé."
    exit 1
fi

echo "[+] Arrêt des services..."
systemctl stop filebeat || true
systemctl stop kibana || true
systemctl stop elasticsearch || true
systemctl stop suricata || true

echo "[+] Suppression des paquets..."
apt remove --purge -y elasticsearch kibana filebeat suricata
apt autoremove -y
apt clean

echo "[+] Suppression des fichiers de configuration..."
rm -rf /etc/elasticsearch /var/lib/elasticsearch /var/log/elasticsearch
rm -rf /etc/kibana /var/lib/kibana /var/log/kibana
rm -rf /etc/filebeat /var/lib/filebeat /var/log/filebeat
rm -rf /etc/suricata /var/log/suricata

echo "[✓] Désinstallation complète effectuée."
