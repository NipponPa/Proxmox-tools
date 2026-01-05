# Intel Undervolt Configuration

Configuration file for `intel-undervolt` CPU/GPU undervolting on an Intel i5-8500T.  

**Placement:**  
Copy the file to `/etc/intel-undervolt.conf`

**Usage:** apply automatically at boot via cron:

```bash
@reboot /bin/bash -c 'sleep 180; /usr/sbin/modprobe msr; /usr/bin/intel-undervolt apply'
```