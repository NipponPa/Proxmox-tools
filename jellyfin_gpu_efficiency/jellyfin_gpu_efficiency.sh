#!/bin/bash
FREQS=(1100 1000 900 800 700 600 500)
VIDEO="/test.mp4"

for f in "${FREQS[@]}"; do
    echo "Testing $f MHz"
    echo 350 > /sys/class/drm/card0/gt_min_freq_mhz
    echo $f > /sys/class/drm/card0/gt_max_freq_mhz

    ENERGY_BEFORE=$(cat /sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj)
    
    # Start transcode (blocking)
    ffmpeg -hwaccel qsv -i "$VIDEO" -c:v hevc_qsv -f null - 2>&1 | tee transcode.log
    
    ENERGY_AFTER=$(cat /sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj)
    
    FRAMES=$(grep "frame=" transcode.log | tail -1 | awk '{print $2}') # adjust for your log
    ENERGY_J=$(( (ENERGY_AFTER - ENERGY_BEFORE)/1000000 ))
    
    echo "$f MHz: $FRAMES frames, $ENERGY_J J, $(echo "$FRAMES / $ENERGY_J" | bc -l) frames/J"
done
