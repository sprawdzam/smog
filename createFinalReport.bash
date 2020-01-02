for metric in 'pm25' 'pm10' 'pm1'
do
 echo "processing files [reports/${metric}.*.q?.md]"
 echo "city|street|#|avg ${metric}|${metric}>25|${metric}>50|${metric}>100|${metric}>200|${metric}>300|${metric}>400|data file" > reports/${metric}.all.md
 echo '---|---|---|---|---|---|---|---|---|---|---' >> reports/${metric}.all.md
 cat reports/${metric}.*.q?.md \
  | grep -v 'data file' \
  | grep -v '|--' \
  | sort -t '|' -k1,1 -k2,2 -k11,11  \
  >> reports/${metric}.all.md
done
