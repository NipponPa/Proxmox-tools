# CPU Power & P-State Tuning

This README contains the crontab entries used to apply CPU power limits, Intel P-state settings, and Powertop auto-tuning at boot.  
Tested on Intel i5-8500T.

## Crontab entries

Add these lines to crontab with `crontab -e`:

```bash
@reboot /bin/sleep 120 && /bin/sh -c 'for f in /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference; do [ -w "$f" ] && echo power > "$f"; done'
@reboot (sleep 120 && echo "powersave" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor)
@reboot sleep 10 && echo 20 > /sys/devices/system/cpu/intel_pstate/min_perf_pct
@reboot sleep 10 && echo 35 > /sys/devices/system/cpu/intel_pstate/max_perf_pct
@reboot sleep 10 && echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo
@reboot sleep 10 && echo 1 > /sys/devices/system/cpu/intel_pstate/energy_efficiency
@reboot sleep 10 && echo 0 > /sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost
@reboot sleep 90 && echo 600 > /sys/class/drm/card0/gt_max_freq_mhz
@reboot sleep 90 && echo 600 > /sys/class/drm/card0/gt_boost_freq_mhz
@reboot sleep 60 && /usr/sbin/powertop --auto-tune
```

