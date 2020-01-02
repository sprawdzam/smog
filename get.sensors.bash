for dbFile in $(ls -1 airly.sqlite.20*.q*)
do
 echo "processing [${dbFile}]"
 # fixes
 echo "update sensor set street='-' where street = '';" | sqlite3 ${dbFile}
 # get data
 echo 'select city,street,id from sensor order by city,street;' \
  | sqlite3 ${dbFile} \
  | column -t -s '|' \
  > sensors/sensors.${dbFile}.txt
done
