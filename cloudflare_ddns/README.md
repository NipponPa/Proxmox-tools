# Cloudflare DDNS Updater

Bash script to automatically update your Cloudflare A record(s) to your current WAN IP.  
Logs all activity to `/cloudflare/cloudflare.log`.  

## Usage

Run automically using crontab:

```bash
*/5 * * * * ~/cloudflare/cloudflare_ddns.sh >/dev/null 2>&1
```
