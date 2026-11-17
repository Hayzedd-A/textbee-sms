#!/usr/bin/env bash
# One-time provisioning for the TextBee native (non-Docker) deployment on the droplet.
# Assumes: Ubuntu, nginx already installed and running for other sites, MongoDB is Atlas (not local).
# Run as a user with sudo. Review each section before running — this isn't meant to be fully unattended.
set -euo pipefail

# --- Node.js 24.x ---
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
sudo apt-get install -y nodejs

# --- pnpm + pm2 ---
sudo npm install -g pnpm pm2

# --- Redis (local only, not exposed) ---
sudo apt-get install -y redis-server
sudo sed -i 's/^bind .*/bind 127.0.0.1 -::1/' /etc/redis/redis.conf
sudo systemctl restart redis-server
sudo systemctl enable redis-server

# --- certbot for nginx (if not already installed for other sites) ---
sudo apt-get install -y certbot python3-certbot-nginx

echo "Base packages installed. Next steps:"
echo "1. git clone git@github.com:Intelia/zupa-sms-service.git /opt/textbee"
echo "2. cp deploy/api.env.example /opt/textbee/api/.env   # fill in Atlas URI, Firebase, SMTP"
echo "3. cp deploy/web.env.example /opt/textbee/web/.env   # fill in domain, NEXTAUTH_SECRET"
echo "4. (cd /opt/textbee/api && pnpm install && pnpm build)"
echo "5. (cd /opt/textbee/web && pnpm install && pnpm build)"
echo "6. sudo cp deploy/nginx/textbee.conf /etc/nginx/sites-available/textbee.conf"
echo "   # edit server_name to the real subdomain first"
echo "7. sudo ln -s /etc/nginx/sites-available/textbee.conf /etc/nginx/sites-enabled/"
echo "8. sudo nginx -t && sudo systemctl reload nginx"
echo "9. sudo certbot --nginx -d sms.zupa.work"
echo "10. (cd /opt/textbee && pm2 start deploy/ecosystem.config.js && pm2 save)"
echo "11. pm2 startup   # run the printed command once"
