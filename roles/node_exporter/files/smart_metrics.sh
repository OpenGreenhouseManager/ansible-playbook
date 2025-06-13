#!/bin/bash

OUTPUT_FILE="/var/lib/node_exporter/textfile_collector/smart_metrics.prom"
DEVICE="/dev/sda"

# Read SMART attributes
TEMP=$(smartctl -A "$DEVICE" | awk '/Temperature_Celsius|194/ {print $10; exit}')

# Fallback if not found
if [[ -z "$TEMP" ]]; then
  echo "# SMART temperature not found" > "$OUTPUT_FILE"
  exit 1
fi

# Write metric
echo "# HELP ssd_temp_celsius SMART temperature" > "$OUTPUT_FILE"
echo "# TYPE ssd_temp_celsius gauge" >> "$OUTPUT_FILE"
echo "ssd_temp_celsius $TEMP" >> "$OUTPUT_FILE"
