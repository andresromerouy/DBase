---
title: 'Análisis del sentimiento -- La reputación de las aerolíneas en Twitter'
author: 'Miguel Ángel Canela'
date: '3 de junio de 2019'
output:
  ioslides_presentation: default
  beamer_presentation: default
---

# Análisis del sentimiento

## Análisis del sentimiento

- **Análisis del sentimiento**: Determinar la actitud de una población.

- **Polaridad**: Medida numérica que hace operativa la medición del sentimiento.

- El enfoque más sencillo: Positivo/negativo.

## Términos positivos y negativos

- Términos positivos: @JetBlue Cabin crew had a **smile** on their faces from runway to runway. Captain did a **great** announcement at front of cabin pre-flight.

> - Términos negativos: I have experienced **hell** and it is an @AmericanAir terminal at night after they've **delayed**, then **cancelled**, all of their flights.

# La reputación de las aerolíneas en Twitter

## Cuestiones

- Cómo calcularías la polaridad, a partir de estos datos?

- ¿Hasta qué punto podemos reproducir el ranking de ACSI con datos de Twitter?

- ¿Debemos excluir los retweets, puesto que no aportan información nueva?

- Si hacemos un seguimiento de la reputación de las aerolíneas en el que hacemos un análisis semanal, ¿podemos esperar que los datos sean consistentes, de forma que el ranking varíe poco de una semana a otra?

## American Customer Satisfaction Index

- ACSI (http://www.theacsi.org/index.php).

- ACSI benchmarks by industry.

- Aerolíneas en 2019: Alaska Airlines (80), JetBlue Airlines (79), Southwest Airlines (79), Delta Airlines (75), American Airlines (73), Allegiant Air (71), United Airlines (70), Frontier Airlines (64) y Spirit Airways (63).

## Captura de datos

- Twitter Search API.

- Fechas: de 2018-12-01 a 2019-02-28.

- Strings de búsqueda: @AlaskaAir (78.183), @Allegiant (6.157), @AmericanAir (213.935), @Delta (213.203), @FlyFrontier (11.363), @JetBlue (63.189), @SouthwestAir (125.047), @SpiritAirlines (18.367) y @united (147.012).

## Estadística descriptiva

- Tweets en inglés: 822.768 (93.9%).

> - Tweets por compañía: Delta (201.367), AmericanAir (200.269), united (138.259), SouthwestAir (119.576), AlaskaAir (71.144), JetBlue (58.416), SpiritAirlines (17.094), FlyFrontier (10.739), Allegiant (5.904).

> - Longitud media de los tweets: AmericanAir (149.2), FlyFrontier (145.4), united (143.0), Delta (137.3), Allegiant (135.7), SouthwestAir (130.9), AlaskaAir (129.1), JetBlue (128.6), SpiritAirlines (128.3).

> - Porcentaje de retweets: AmericanAir (39,7%), JetBlue (35,9%), Delta (35,2%), united (33,4%), Allegiant (31,9%), AlaskaAir (29,5%), FlyFrontier (26,3%), SouthwestAir (25,4%), SpiritAirlines (20,8%).

## Tablas de datos

| tweet_id | is_retweet | positive | negative | 
| :------: |:-----:|:-----:| :-----:|
| 1 | 0 | 0 | 0 |
| 2 | 0 | 0 | 0 |
| 3 | 0 | 1 | 0 |
| 4 | 1 | 2 | 0 |
| 5 | 1 | 1 | 0 |

## Método 1

- Tweet positivo: positive > negative.

- Tweet negativo: positive < negative.

- Tweet neutral: positive = negative.

- Polaridad = (# Tweets positivos) / (# Tweets negativos)

## Comparación 1

| Aerolínea | Score ACSI | Con retweets | Sin retweets | 
| :------ |:-----:|:-----:| :-----:|
| AlaskaAir | 80 | 4,42 | 3.76 |
| JetBlue | 79 | 2,12 | 1,78 |
| SouthwestAir | 79 | 2,28 | 2,09 |
| Delta | 75 | 2,22 | 1,99 |
| AmericanAir | 73 | 1,52 | 1,32 |

## Continuación

| Aerolínea | Score ACSI | Con retweets | Sin retweets | 
| :------ |:-----:|:-----:| :-----:|
| Allegiant | 71 | 2,42 | 1,67 |
| United | 70 | 1,62 | 1,53 |
| FlyFrontier | 64 | 1,57 | 1,16 | 
| SpiritAirlines | 63 | 1,10 | 0,95 | 

## Método 2

- Score = (Positive - Negative) / (Positive + Negative)

- Polaridad = promedio de los scores

## Comparación 2

| Aerolínea | Score ACSI | Con retweets | Sin retweets | 
| :------ | :-----:| :-----: | :-----: |
| AlaskaAir | 80 | 0,58 | 0,52 |
| JetBlue | 79 | 0,32 | 0,22 |
| SouthwestAir | 79 | 0,34 | 0,30 |
| Delta | 75 | 0,32 | 0,28 |
| AmericanAir | 73 | 0,19 | 0,12 |

## Continuación

| Aerolínea | Score ACSI | Con retweets | Sin retweets | 
| :------ |:-----:|:-----:| :-----:|
| Allegiant | 71 | 0,37 | 0,22 |
| United | 70 | 0,20 | 0,18 |
| FlyFrontier | 64 | 0,10 | 0,07 | 
| SpiritAirlines | 63 | 0,04 | -0,02 | 

## ¿Es consistente este sistema?

| Aerolínea | S1 | S2 | S3 | S4 | S5 | S6 | 
| :------ |:-----:|:-----:| :-----:|:-----:|:-----:| :-----:|
| AlaskaAir | 0,28 | 0,27 | 0,24 | 0,23 | 0,11 | 0,09 |
| Allegiant | 0,08 | 0,19 | 0,02 | -0,20 | -0,03 | 0,03 |
| AmericanAir | -0,01 | 0,09 | -0,09 | -0,25 | -0,13 | -0,01 |
| Delta | 0,18 | 0,15 | 0,10 | 0,02 | 0,02 | 0,14 |
| FlyFrontier | -0,16 | -0,16 | -0,12 | -0,26 | -0,25 | 0,06 |

## Continuación

| Aerolínea | S1 | S2 | S3 | S4 | S5 | S6 | 
| :------ |:-----:|:-----:| :-----:|:-----:|:-----:| :-----:|
| JetBlue | 0,12 | 0,08 | -0,03 | -0,03 | -0,04 | 0,17 |
| SouthwestAir | 0,28 | 0,22 | 0,07 | 0,00 | 0,12 | 0,21 |
| SpiritAirlines | -0,18 | -0,14 | -0,17 | -0,37 | -0,21 | -0,24 | 
| United | 0,01 | -0,04 | -0,03 | -0,10 | -0,08 | 0,04 |

## ¿Qué hemos aprendido?

> - Las redes sociales como fuente potencial de datos.

> - Investigación de mercado sin moverse de la oficina.

> - Nadie tiene la última palabra sobre la inclusión de los retweets en el análisis de los datos de Twitter.

> - En Big Data, el volumen puede compensar la baja calidad de los datos.
