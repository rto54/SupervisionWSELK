# 🛡️ VM Proxmox – Supervision Wazuh + Suricata + ELK

## 📦 Description

Cette machine virtuelle Proxmox centralise la supervision réseau et système avec :
- **Wazuh** (HIDS)
- **Suricata** (IDS réseau)
- **Elasticsearch + Kibana** (stockage & visualisation)
- **Filebeat** (collecte de logs)

---

## ⚙️ Configuration recommandée (Proxmox)

- **VMID** : 9000
- **CPU** : 4 vCores
- **RAM** : 16 Go
- **Disque** : 150 Go (SCSI, local-lvm)
- **Réseau** : virtio, bridge `vmbr0`

---

## 📁 Fichier Proxmox

Copier le fichier `9000.conf` vers :

```bash
/etc/pve/qemu-server/9000.conf
```

Puis démarrer la VM avec un ISO Debian 12.

---

## 🧰 Installation de la stack

1. Installer Debian 12 dans la VM
2. Copier les scripts suivants :
   - `install-elk-suricata.sh`
   - `install-configure-wazuh-agent-linux.sh`
   - `generate-kibana-report.sh`
3. Exécuter :

```bash
chmod +x install-elk-suricata.sh
sudo ./install-elk-suricata.sh
```

## 🧰 Déploiement Agent Wazuh (Linux)


```bash
chmod +x install-elk-suricata.sh
sudo ./install-elk-suricata.sh
```

---

## 🌐 Accès Kibana

Ouvrir dans un navigateur :

```
http://<IP_VM>:5601
```

---

## 🗂️ Import du Dashboard Fusionné

Depuis Kibana :
1. Aller dans **Stack Management > Saved Objects**
2. Cliquer sur **Import**
3. Sélectionner le fichier : `kibana-dashboard-suricata-wazuh.ndjson`

---

## 📤 Génération de rapport PDF

Configurer et lancer :

```bash
chmod +x generate-kibana-report.sh
./generate-kibana-report.sh
```

Modifiez le script pour insérer vos identifiants SMTP Gmail.

---

## 🧹 Désinstallation

```bash
chmod +x uninstall-elk-suricata.sh
sudo ./uninstall-elk-suricata.sh
```

---

## ✅ Astuce : Automatisation via Cron

Pour exécuter un rapport chaque jour à 8h :

```bash
crontab -e
```

Ajouter :

```bash
0 8 * * * /chemin/generate-kibana-report.sh
```
