#!/bin/bash

curl -s "https://aviationweather.gov/api/data/metar?ids=KMCI&format=json&taf=false&hours=12&bbox=40%2C-90%2C45%2C-85" > aviation.json

jq -r '.[].receiptTime' aviation.json | head -n 6

temps=($(jq '.[].temp' aviation.json))

sum=0
count=0
for t in "${temps[@]}"; do
  if [[ "$t" != "null" ]]; then
    sum=$(echo "$sum + $t" | bc)
    ((count++))
  fi
done

if [ "$count" -eq 0 ]; then
  avg_temp="N/A"
else
  avg_temp=$(echo "scale=1; $sum / $count" | bc)
fi

echo "Average Temperature: $avg_temp"

clouds=($(jq -r '.[].cloud' aviation.json))
cloudy_count=0
total_count=0

for cloud in "${clouds[@]}"; do
  ((total_count++))
  if [[ "$cloud" != "CLR" ]]; then
    ((cloudy_count++))
  fi
done

if (( cloudy_count > total_count / 2 )); then
  echo "Mostly Cloudy: true"
else
  echo "Mostly Cloudy: false"
fi
