for metric in 'pm25' 'pm10' 'pm1'
do
 for dbFile in $(ls -1 airly.sqlite.20*.q*)
 do
  if [[ ! -f reports/${metric}.${dbFile}.md ]];then
   echo "file [reports/${metric}.${dbFile}.md]"
   sensorIds="$(sqlite3 ${dbFile} 'SELECT id FROM sensor ORDER BY id')"
   for sensorId in ${sensorIds}
   do
    echo "${metric} : ${dbFile} : ${sensorId}"
    echo "
    SELECT *,'${dbFile}' FROM (
     (SELECT city, street FROM sensor where id='${sensorId}'),
     (SELECT count(*) FROM measurement WHERE sensorId='${sensorId}'),
     (SELECT round(avg(${metric}),2) FROM measurement WHERE sensorId='${sensorId}'),
     (SELECT count(*) FROM measurement WHERE sensorId='${sensorId}' AND ${metric}>25),
     (SELECT count(*) FROM measurement WHERE sensorId='${sensorId}' AND ${metric}>50),
     (SELECT count(*) FROM measurement WHERE sensorId='${sensorId}' AND ${metric}>100),
     (SELECT count(*) FROM measurement WHERE sensorId='${sensorId}' AND ${metric}>200),
     (SELECT count(*) FROM measurement WHERE sensorId='${sensorId}' AND ${metric}>300),
     (SELECT count(*) FROM measurement WHERE sensorId='${sensorId}' AND ${metric}>400)
    )" | sqlite3 ${dbFile} >> reports/${metric}.${dbFile}.md
   done
   sed -i 's/||/|-|/g;s/||/|-|/g;s/|0|/|-|/g;s/|0|/|-|/g;s/airly.sqlite.//' reports/${metric}.${dbFile}.md
   cat reports/${metric}.${dbFile}.md \
    |grep -v '|-|-|-|-|-|-|-|' \
    | sort -k 1,2 -t'|' \
    > reports/${metric}.${dbFile}.md.sorted
 
   echo "city|street|#|avg ${metric}|${metric}>25|${metric}>50|${metric}>100|${metric}>200|${metric}>300|${metric}>400|data file" > reports/${metric}.${dbFile}.md
   echo '---|---|---|---|---|---|---|---|---|---|---' >> reports/${metric}.${dbFile}.md
   cat reports/${metric}.${dbFile}.md.sorted >> reports/${metric}.${dbFile}.md
   rm reports/${metric}.${dbFile}.md.sorted
  else
   echo "file [reports/pm25.${dbFile}.md] exists, skipping"
  fi
 done
 
done
