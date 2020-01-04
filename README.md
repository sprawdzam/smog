# Dane historyczne zebrane z wybranych czujników airly

Pliki z danymi są stworzone na podstawie odczytów czujników airly i nazwane zgodnie z rokiem i kwartałem, do którego należy np. airly.sqlite.2018.q1.zip
W celu analizy danych można wykorzystać przeglądarkę z dodatkiem sqlite-manager, który można znleźć tutaj:
* https://chrome.google.com/webstore/detail/sqlite-manager/njognipnngillknkhikjecpnbkefclfe
* https://add0n.com/sqlite-manager.html

Przed analizą pliki z danymi należy rozpakować

Gotowe raporty, z tabelami przedstawiającymi ilość godzin, dla których dany poziom był przekroczony znajdują się w katalogu `reports`. Spis czujników znajduje się w katalogu `sensors`.

## Komendy pomocne w analizie 

Struktura bazy danych

    SELECT name FROM sqlite_master WHERE type='table'

Dostępne tabele
* sensor : lista sensorów z ich lokalizacją
* measurment : lista odczytów dla każdego sensora

Struktura danej tableli

    PRAGMA table_info(measurement)

Wyszukiwanie sensorów:

     SELECT id,city,street,vendor FROM sensor ORDER BY city

Przykładowo wybieramy sensor z id 304 
Dane jakie możemy dla niego odczytać to:
* airQualityIndex
* pm1
* pm10
* pm25
* pressure
* humidity
Dostępność danych może się różnić w zależności od typu sensora.

Dane pozwalają na samodzielne analizy jakości powietrza.
Przykładowe analizy wraz z kodem zapytań do wpisania w dodatku sqlite-manager podano poniżej.

Ilość godzin, kiedy limit pm25 był przekroczony dla całego zakresu danych

    SELECT count(*) FROM measurement WHERE sensorId='304' AND pm25>25

Lista wskazująca gdzie było najwięcej godzin o przekroczonej normie pm25

    SELECT sensor.city, sensor.street, COUNT(*) as 'hours'
    FROM sensor, measurement
    WHERE
     sensor.id=measurement.sensorId
     AND pm25>25
    GROUP BY sensor.id
    ORDER BY hours DESC

Lista wskazująca gdzie była najgorsza średnia wartości pm25 dla wszystkich dostępnych danych

    SELECT sensor.city, sensor.street, AVG(pm25) as 'avg', count(*) as 'samples'
    FROM sensor, measurement
    WHERE sensor.id=measurement.sensorId
    GROUP BY sensor.id
    ORDER BY avg DESC

Lista wskazująca gdzie była najgorsza średnia wartości pm25 dla próbek gdzie norma była przekroczona

    SELECT sensor.city, sensor.street, AVG(pm25) as 'avg', count(*) as 'samples'
    FROM sensor, measurement
    WHERE
     sensor.id=measurement.sensorId
     AND pm25>25
    GROUP BY sensor.id
    ORDER BY avg DESC

Lista wskazująca ile godzin znajduje się w danym przedziale zanieczyszczenia dla wybranego sensora

    SELECT * FROM (
     (SELECT sensor.city, sensor.street FROM sensor where id='304'),
     (SELECT count(*) AS 'pm25>25' FROM measurement WHERE sensorId='304' AND pm25>25),
     (SELECT count(*) AS 'pm25>50' FROM measurement WHERE sensorId='304' AND pm25>50),
     (SELECT count(*) AS 'pm25>100' FROM measurement WHERE sensorId='304' AND pm25>100),
     (SELECT count(*) AS 'pm25>200' FROM measurement WHERE sensorId='304' AND pm25>200),
     (SELECT count(*) AS 'pm25>300' FROM measurement WHERE sensorId='304' AND pm25>300),
     (SELECT count(*) AS 'pm25>400' FROM measurement WHERE sensorId='304' AND pm25>400)
    )

Rysowanie wykresów

Wybieramy dane do wykresu

    SELECT fromDateTime, pm25 FROM measurement WHERE sensorId='304' | import as plot_data

... konkretne punkty

    x=plot_data[:,1]
    y=plot_data[:,2]

... i rysujemy

    plot(x, y, "type=line&parser=YYYY-MM-DD[T]HH:mm:ss[Z]")

Normy w Polsce (za http://www.gios.gov.pl/pl/aktualnosci/294-normy-dla-pylow-drobnych-w-polsce)

 * poziom dobowy pm10 - dopuszczalny 50 µg/m3
 * poziom dobowy pm10 - informowania 200 µg/m3
 * poziom dobowy pm10 - alarmowy 300 µg/m3

Zalecenia w EU (za https://www.eea.europa.eu/themes/air/air-quality-concentrations/air-quality-standards)

 * poziom roczny pm25 25 μg/m3
 * poziom roczny pm10 40 μg/m3
 * poziom godzinny pm10 50 μg/m3
 * poziom 8-godzinny O3 120 μg/m3
 * poziom roczny NO2 40 μg/m3
 * poziom godzinny NO2 200 μg/m3

Poziomy alarmowe pm10 w EU (za https://www.levego.hu/sites/default/files/smog_emergency_schemes_in_europe_201703.pdf)

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

Normy w USA (za https://www3.epa.gov/region1/airquality/pm-aq-standards.html)

 * poziom roczny pm25 12 μg/m3
 * poziom dobowy pm25 35 μg/m3
 * poziom roczny pm10 50 μg/m3 (obecenie nie obowiązuje)
 * poziom dobowy pm10 150 μg/m3

Zalecenia WHO (za https://apps.who.int/iris/bitstream/handle/10665/69477/WHO_SDE_PHE_OEH_06.02_eng.pdf;sequence=1)

 * poziom roczny pm25 10 μg/m3
 * poziom dobowy pm25 25 μg/m3
 * poziom roczny pm10 20 μg/m3
 * poziom dobowy pm10 50 μg/m3
 * poziom 8-godzinny O3 100 μg/m3
 * poziom roczny NO2 40 μg/m3
 * poziom godzinny NO2 200 μg/m3
 * poziom dobowy SO2 20 μg/m3
 * poziom 10-minutowy SO2 500 μg/m3

Inne linki:

 * https://www.eea.europa.eu/themes/air/country-fact-sheets/2019-country-fact-sheets/poland
