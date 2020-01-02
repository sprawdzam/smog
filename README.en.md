# Historic data from airly sensors

Data files are taken from airly sensors and named according to year and quarter, e.g. airly.sqlite.2018.q1.zip
To analyze them you can use chrome extension sqlite-manager, to be found here:
* https://chrome.google.com/webstore/detail/sqlite-manager/njognipnngillknkhikjecpnbkefclfe
* https://add0n.com/sqlite-manager.html

Before runing analysis, make sure that data files are unziped

Ready reports, with tables including number of hours where specyfic levels were exceeded are stored in directory `reports`. Sensonrs are listed in directory `sensors`.

## Examples od analysis

Check DB structure

    SELECT name FROM sqlite_master WHERE type='table'

Available tables
* sensor : list of sensors & locations
* measurment : list od sensor data

Getting table structure

    PRAGMA table_info(measurement)

Sensor listing:

     SELECT id,city,street,vendor FROM sensor ORDER BY city

As example, let's pick sensor with id 519 (Wieliczka, Adama Asnyka)
Data that can be read:
* airQualityIndex
* pm1
* pm10
* pm25
* pressure
* humidity
Data availablity may change depending on sensor type

Data make it possible to analyze air quiality under picked categories
Some exaples are given below.


    SELECT count(*) FROM measurement WHERE sensorId='519' AND pm25>25

Get count of hours where limit for pm25 was exceeded

    SELECT sensor.city, sensor.street, COUNT(*) as 'hours'
    FROM sensor, measurement
    WHERE
     sensor.id=measurement.sensorId
     AND pm25>25
    GROUP BY sensor.id
    ORDER BY hours DESC

Get list ordered by the worst (avg pm25 value for all samples)

    SELECT sensor.city, sensor.street, AVG(pm25) as 'avg', count(*) as 'samples'
    FROM sensor, measurement
    WHERE sensor.id=measurement.sensorId
    GROUP BY sensor.id
    ORDER BY avg DESC

Get list ordered by the worst (avg value for samples where limit of pm25 was exceeded)

    SELECT sensor.city, sensor.street, AVG(pm25) as 'avg', count(*) as 'samples'
    FROM sensor, measurement
    WHERE
     sensor.id=measurement.sensorId
     AND pm25>25
    GROUP BY sensor.id
    ORDER BY avg DESC

Get summary for specyfic sensor, showing how bad air was and for how many hours

    SELECT * FROM (
     (SELECT sensor.city, sensor.street FROM sensor where id='519'),
     (SELECT count(*) AS 'pm25>25' FROM measurement WHERE sensorId='519' AND pm25>25),
     (SELECT count(*) AS 'pm25>50' FROM measurement WHERE sensorId='519' AND pm25>50),
     (SELECT count(*) AS 'pm25>100' FROM measurement WHERE sensorId='519' AND pm25>100),
     (SELECT count(*) AS 'pm25>200' FROM measurement WHERE sensorId='519' AND pm25>200),
     (SELECT count(*) AS 'pm25>300' FROM measurement WHERE sensorId='519' AND pm25>300),
     (SELECT count(*) AS 'pm25>400' FROM measurement WHERE sensorId='519' AND pm25>400)
    )

Plotting the data

    SELECT fromDateTime, pm25 FROM measurement WHERE sensorId='519' | import as plot_data
    x=plot_data[:,1]
    y=plot_data[:,2]
    plot(x, y, "type=line&parser=YYYY-MM-DD[T]HH:mm:ss[Z]")

Levels in Poland (as in http://www.gios.gov.pl/pl/aktualnosci/294-normy-dla-pylow-drobnych-w-polsce)

 * pm10 acceptable daily level - 50 µg/m3
 * pm10 information level - 200 µg/m3
 * pm10 alarm level - 300 µg/m3

EU recommendations (as in https://www.eea.europa.eu/themes/air/air-quality-concentrations/air-quality-standards)

 * poziom roczny pm25 25 μg/m3
 * poziom roczny pm10 40 μg/m3
 * poziom godzinny pm10 50 μg/m3
 * poziom 8-godzinny O3 120 μg/m3
 * poziom roczny NO2 40 μg/m3
 * poziom godzinny NO2 200 μg/m3

EU pm10 alarm levels (as in https://www.levego.hu/sites/default/files/smog_emergency_schemes_in_europe_201703.pdf)

 * .at - 75 µg/m3
 * .ba - 400 µg/m3
 * .be - 70 µg/m3
 * .ch - 100 µg/m3
 * .cz - 150 µg/m3
 * .de - 50 µg/m3
 * .es - 80 µg/m3
 * .fi - 50 µg/m3
 * .fr - 80 µg/m3
 * .hu - 100 µg/m3
 * .it - 75 µg/m3
 * .no - 150 µg/m3
 * .mk - 100 µg/m3
 * .pl - 300 µg/m3
 * .sk - 150 µg/m3
 * .uk - 101 µg/m3

USA acceptable levels (as in https://www3.epa.gov/region1/airquality/pm-aq-standards.html)

 * pm25 12 μg/m3 yearly
 * pm25 35 μg/m3 daily
 * pm10 50 μg/m3 (not valid anymore) yearly
 * pm10 150 μg/m3 daily

WHO recommendations (as in https://apps.who.int/iris/bitstream/handle/10665/69477/WHO_SDE_PHE_OEH_06.02_eng.pdf;sequence=1)

 * poziom roczny pm25 10 μg/m3
 * poziom dobowy pm25 25 μg/m3
 * poziom roczny pm10 20 μg/m3
 * poziom dobowy pm10 50 μg/m3
 * poziom 8-godzinny O3 100 μg/m3
 * poziom roczny NO2 40 μg/m3
 * poziom godzinny NO2 200 μg/m3
 * poziom dobowy SO2 20 μg/m3
 * poziom 10-minutowy SO2 500 μg/m3

Other links:

 * https://www.eea.europa.eu/themes/air/country-fact-sheets/2019-country-fact-sheets/poland
