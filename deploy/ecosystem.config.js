// pm2 process file for the native (non-Docker) TextBee deployment.
// From the repo root on the droplet, after building api/ and web/:
//   pm2 start deploy/ecosystem.config.js
//   pm2 save
//   pm2 startup   (follow the printed systemd command once, so pm2 survives reboots)
module.exports = {
  apps: [
    {
      name: 'textbee-api',
      cwd: './api',
      script: 'dist/main.js',
      env: {
        NODE_ENV: 'production',
      },
    },
    {
      name: 'textbee-web',
      cwd: './web',
      script: 'pnpm',
      args: 'start',
      env: {
        NODE_ENV: 'production',
      },
    },
  ],
}
