 create database if not exists airline_delayDB;


select * from flights_delay limit 10;

select avg(arrival_delay) from flights_delay where ARRIVAL_DELAY > 0 and ARRIVAL_DELAY is not null;

-- Days of months with respected to average of arrival delays
select day, avg(arrival_delay) from flights_delay where arrival_delay is not null and arrival_delay > 0 group by day;

-- Arrange weekdays with respect to the average arrival delays caused
 select day_of_week, avg(arrival_delay) from flights_delay group by DAY_OF_WEEK;
 
 -- Arrange Days of month as per cancellations done in Descending
 select day, count(cancelled) as cancelled from flights_delay group by day having CANCELLED <> 0 and CANCELLED is not null order by day desc ;
 
 -- Finding busiest airports with respect to day of week
WITH airport_counts AS (
  SELECT ORIGIN_AIRPORT, DAY_OF_WEEK, COUNT(*) AS num_flights,
         ROW_NUMBER() OVER (PARTITION BY DAY_OF_WEEK ORDER BY COUNT(*) DESC) AS flight_rank
  FROM Flights_Delay
  GROUP BY ORIGIN_AIRPORT, DAY_OF_WEEK
)
SELECT ORIGIN_AIRPORT, DAY_OF_WEEK, num_flights
FROM airport_counts
WHERE flight_rank = 1;

 
-- i)	Finding airlines that make the maximum number of cancellations
 
select airline, count(cancelled) as cancelled from flights_delay group by airline having cancelled <> 0 and cancelled is not null; 


-- Find and order airlines in descending that make the most number of diversions
select airline, sum(diverted) as divCount from flights_delay where diverted is not null group by airline order by divCount desc;


-- Finding days of month that see the most number of diversion
select day, sum(diverted) as divCount from flights_delay where diverted is not null group by day order by divCount desc;

-- Calculating mean and standard deviation of departure delay for all flights in minutes
select sum(departure_delay)/count(departure_delay) as mean, stddev(DEPARTURE_DELAY)
 from flights_delay where DEPARTURE_DELAY is not null and DEPARTURE_DELAY > 0;


-- m)	Calculating mean and standard deviation of arrival delay for all flights in minutes
select sum(arrival_delay)/count(arrival_delay) as mean, stddev(arrival_delay)
 from flights_delay where ARRIVAL_DELAY is not null and ARRIVAL_DELAY > 0;

-- o)	Create a partitioning table “flights_partition” using suitable partitioned by schema
create table flights_partition(ID int, YEAR int, MONTH int, DAY int, DAY_OF_WEEK int, AIRLINE text, FIGHT_NUMBER int, TAIL_NUMBER int,
ORIGIN_AIRPORT text, DESTINATION_AIRPORT text, DEPARTURE_TIME int, DEPARTURE_DELAY int, DEPATURE_DELAY int, TAXI_OUT int, WHEELS_OFF int,
SCHEDULED_TIME int, ELAPSED_TIME int, AIR_TIME int, DISTANCE int, WHEELS_ON int, TAXI_IN int, SCHEDULED_ARRIVAL int, ARRIVAL_TIME int,
ARRIVAL_DELAY int, DIVERTED int, CANCELLED int) partition by hash(id) partitions 5; 

-- p)	Finding all diverted Route from a source to destination Airport & which route is the most diverted
select concat(origin_airport, " ", destination_airport) as route, sum(DIVERTED) as divCount
from flights_delay group by route order by divCount desc;



-- q)	Write a query to show Top 3 airlines from each airport making most Delays.(Use Dense Rank/ Rank)
SELECT airline, origin_airport, departure_delay + arrival_delay AS total_delay,
  DENSE_RANK() OVER (PARTITION BY origin_airport ORDER BY departure_delay + arrival_delay DESC) AS ranking
FROM Flights_Delay
WHERE departure_delay > 0 OR arrival_delay > 0 and ranking <= 3
GROUP BY origin_airport, airline, departure_delay + arrival_delay
HAVING COUNT(*) >= 3 AND origin_airport IS NOT NULL;



-- r)	Write a query to show Top 10 airlines from each week making most Delays. Find its Ranking.
select * from flights_delay;
select airline from flights_delay;

-- s)	Create a materialized view for client to show Top 10 airlines with highest Delay.
CREATE VIEW top_10_airlines_delay AS
WITH airline_delays AS (
  SELECT AIRLINE, COUNT(*) AS num_delays
  FROM Flights_Delay
  WHERE DEPARTURE_DELAY > 0
  GROUP BY AIRLINE
)
SELECT AIRLINE, num_delays, RANK() OVER (ORDER BY num_delays DESC) AS ranking
FROM airline_delays
WHERE AIRLINE IN (
  SELECT AIRLINE FROM airline_delays ORDER BY num_delays DESC LIMIT 10
);



-- t)	Create a new column named ‘Delay_Comaprison’ showing if flights making higher or lower than average flight delay.
ALTER TABLE Flights_Delay ADD COLUMN Delay_Comparison VARCHAR(10);

ALTER TABLE Flights_Delay ADD COLUMN Delay_Comparison VARCHAR(10);
set sql_safe_updates = 0;
UPDATE Flights_Delay fd
JOIN (
  SELECT AIRLINE, AVG(DEPARTURE_DELAY + ARRIVAL_DELAY) AS avg_delay
  FROM Flights_Delay
  GROUP BY AIRLINE
) AS avg_fd
ON fd.AIRLINE = avg_fd.AIRLINE
SET fd.Delay_Comparison = CASE
  WHEN fd.DEPARTURE_DELAY + fd.ARRIVAL_DELAY > avg_fd.avg_delay THEN 'Higher'
  ELSE 'Lower'
END;


-- u)	Finding AIRLINES with its total flight count, total number of flights arrival delayed by more than 30 Minutes, 
-- % of such flights delayed by more than 30 minutes when it is not Weekends with minimum count of flights from Airlines by more than 10. 
-- Also Exclude some of Airlines 'AK', 'HI', 'PR', 'VI' and arrange output in descending order by % of such count of flights. 
SELECT 
  AIRLINE,
  COUNT(*) AS total_flights,
  SUM(CASE WHEN ARRIVAL_DELAY > 30 THEN 1 ELSE 0 END) AS delayed_flights,
  CONCAT(
    ROUND(SUM(CASE WHEN ARRIVAL_DELAY > 30
    AND DAY_OF_WEEK NOT IN (6, 7) THEN 1 ELSE 0 END) * 100 / NULLIF(SUM(CASE WHEN DAY_OF_WEEK NOT IN (6, 7) THEN 1 ELSE 0 END), 0), 2),
    '%'
  ) AS delayed_percent
FROM Flights_Delay
WHERE AIRLINE NOT IN ('AK', 'HI', 'PR', 'VI')
GROUP BY AIRLINE
HAVING 
  total_flights > 10 AND 
  delayed_percent IS NOT NULL
ORDER BY delayed_percent DESC;



-- v)	Finding AIRLINES with its total flight count with total number of flights departure delayed by less than 30 Minutes,
-- % of such flights delayed by less than 30 minutes when it is Weekends with minimum count of flights from Airlines by more than 10.
-- Also Exclude some of Airlines 'AK', 'HI', 'PR', 'VI' and arrange output in descending order by % of such count of flights. 
SELECT 
  AIRLINE,
  COUNT(*) AS total_flights,
  SUM(CASE WHEN DEPARTURE_DELAY < 30 THEN 1 ELSE 0 END) AS on_time_flights,
  CONCAT(
    ROUND(SUM(CASE WHEN DEPARTURE_DELAY < 30 
    AND DAY_OF_WEEK IN (6, 7) THEN 1 ELSE 0 END) * 100 / NULLIF(SUM(CASE WHEN DAY_OF_WEEK IN (6, 7) THEN 1 ELSE 0 END), 0), 2),
    '%'
  ) AS on_time_percent
FROM Flights_Delay
WHERE AIRLINE NOT IN ('AK', 'HI', 'PR', 'VI')
GROUP BY AIRLINE
HAVING 
  total_flights > 10 AND 
  on_time_percent IS NOT NULL
ORDER BY on_time_percent DESC;


-- w)	When is the best time of day/day of week/time of a year to fly with minimum delays?
SELECT 
  DAY_OF_WEEK, 
  AVG(DEPARTURE_DELAY) AS avg_departure_delay
FROM Flights_Delay
GROUP BY DAY_OF_WEEK
ORDER BY avg_departure_delay ASC;

SELECT 
  MONTH, 
  AVG(DEPARTURE_DELAY) AS avg_departure_delay
FROM Flights_Delay
GROUP BY MONTH
ORDER BY avg_departure_delay ASC;


-- x)	Suggest reasons of airlines delays and suggest, build solutions for it.
SELECT 
    COUNT(CASE WHEN arrival_delay > 0 AND airline_delay IS NOT NULL AND airline_delay >= 0 THEN 1 END) * 100.0 / 
    COUNT(CASE WHEN arrival_delay > 0 OR departure_delay > 0 THEN 1 END) AS airline_delay_percentage_arrival,
    
    COUNT(CASE WHEN departure_delay > 0 AND airline_delay IS NOT NULL AND airline_delay >= 0 THEN 1 END) * 100.0 / 
    COUNT(CASE WHEN arrival_delay > 0 OR departure_delay > 0 THEN 1 END) AS airline_delay_percentage_departure,
    
    COUNT(CASE WHEN arrival_delay > 0 AND weather_delay IS NOT NULL AND weather_delay >= 0 THEN 1 END) * 100.0 / 
    COUNT(CASE WHEN arrival_delay > 0 OR departure_delay > 0 THEN 1 END) AS weather_delay_percentage_arrival,
    
    COUNT(CASE WHEN departure_delay > 0 AND weather_delay IS NOT NULL AND weather_delay >= 0 THEN 1 END) * 100.0 / 
    COUNT(CASE WHEN arrival_delay > 0 OR departure_delay > 0 THEN 1 END) AS weather_delay_percentage_departure
    
FROM 
    flights
WHERE 
    arrival_delay IS NOT NULL 
    OR departure_delay IS NOT NULL;


-- y)	Create a stored procedure to find weeks with maximum flights delays count.
DELIMITER //

CREATE PROCEDURE find_max_delay_weeks()
BEGIN
	DECLARE max_delays INT;
	SELECT COUNT(*) INTO max_delays
	FROM Flights_Delay
	WHERE departure_delay > 0 OR arrival_delay > 0
	GROUP BY WEEK(CONCAT(year, '-', month, '-', day))
	ORDER BY COUNT(*) DESC
	LIMIT 1;
	
	SELECT WEEK(CONCAT(year, '-', month, '-', day)) AS week_num, COUNT(*) AS total_delays
	FROM Flights_Delay
	WHERE departure_delay > 0 OR arrival_delay > 0
	GROUP BY WEEK(CONCAT(year, '-', month, '-', day))
	HAVING COUNT(*) = max_delays;
END //
DELIMITER ;

call find_max_delay_weeks()
