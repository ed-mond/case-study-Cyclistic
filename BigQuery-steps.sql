-- Queries used in BigQuery to analyze dataset

/* Join the two datasets into one single dataset.
Q2 and Q3 datasets were too large for thee free tier of BigQuery */
SELECT * FROM `smooth-guru-386204.google_case_study_1.Divvy_Trips_2019_Q1`
UNION ALL
SELECT * FROM `smooth-guru-386204.google_case_study_1.Divvy_Trips_2019_Q4`

-- Adding ride_length calculation to table
SELECT  
  start_time, 
  end_time, 
  TIMESTAMP_DIFF(end_time, start_time, MINUTE) AS ride_length
FROM `smooth-guru-386204.google_case_study_1.Divvy_Trips_2019_Combined` 
LIMIT 1000

-- Create column for ride_length and insert values
ALTER TABLE `smooth-guru-386204.google_case_study_1.Divvy_Trips_2019_Combined`
ADD COLUMN ride_length NUMERIC;

UPDATE `smooth-guru-386204.google_case_study_1.Divvy_Trips_2019_Combined`
SET ride_length = TIMESTAMP_DIFF(end_time, start_time, MINUTE);

/* BigQuery doesn't allow DML queries without payment, so the above query doesn't work.
Resorting to in table calculations.*/

-- Dropping previous ride_length column since it is not needed
ALTER TABLE `smooth-guru-386204.google_case_study_1.Divvy_Trips_2019_Combined`
DROP COLUMN ride_length;

/* Query with the additional columns needed for later analysis & save as a new table (Divvy_Trips_Clean).
DAYOFWEEK = 1 = Sunday */
SELECT  
  trip_id,
  start_time, 
  end_time,
  bikeid,
  usertype,
  gender,
  birthyear,
  TIMESTAMP_DIFF(end_time, start_time, MINUTE) AS ride_length, 
  EXTRACT(DAYOFWEEK FROM start_time) AS day_of_week
FROM `smooth-guru-386204.google_case_study_1.Divvy_Trips_2019_Combined`

-- Calculate average ride length for each user type
SELECT
  usertype,
  AVG(ride_length) AS avg_ride_length,
FROM `smooth-guru-386204.google_case_study_1.Divvy_Trips_Clean`
GROUP BY usertype

/*
usertype	avg_ride_length
Subscriber	12.513391631533807
Customer	60.739364703881684
*/

-- Calculate mode of day_of_week for each user type
SELECT
  usertype,
  APPROX_TOP_COUNT(day_of_week, 1) AS mode,
FROM `smooth-guru-386204.google_case_study_1.Divvy_Trips_Clean`
GROUP BY usertype

/*
Subscriber = 3 (Tue), Count = 168055
Customer = 1 (Sun), Count = 29099
*/

-- Calculate total count per day of week for Subscribers
SELECT
  day_of_week,
  COUNT(trip_id) AS trip_ct,
FROM `smooth-guru-386204.google_case_study_1.Divvy_Trips_Clean`
WHERE usertype = 'Subscriber'
GROUP BY day_of_week
ORDER BY trip_ct DESC
  
/*  
day_of_week	trip_ct
3	168055
5	160949
4	152537
6	150732
2	148930
7	80239
1	78324
*/

-- Average ride length for subscribers on weekdays
SELECT
  AVG(ride_length) AS avg_ride_length,
FROM `smooth-guru-386204.google_case_study_1.Divvy_Trips_Clean`
WHERE usertype = 'Subscriber'
  AND day_of_week != 1
  AND day_of_week != 7

-- Subscriber average weekday ride length = 12.1 mins

-- Average ride length for subscribers on weekends
SELECT
  AVG(ride_length) AS avg_ride_length,
FROM `smooth-guru-386204.google_case_study_1.Divvy_Trips_Clean`
WHERE usertype = 'Subscriber'
  AND day_of_week = 1
  OR day_of_week = 7

-- Subscriber average weekend ride length = 21.1 mins
  
-- Calculate total count per day of week for Customers
SELECT
  day_of_week,
  COUNT(trip_id) AS trip_ct,
FROM `smooth-guru-386204.google_case_study_1.Divvy_Trips_Clean`
WHERE usertype = 'Subscriber'
GROUP BY day_of_week
ORDER BY trip_ct DESC
  
/*  
day_of_week	trip_ct
1	29099
7	26687
6	16278
5	15126
3	14769
2	14682
4	12716
*/

-- Average ride length for customers on weekdays
SELECT
  AVG(ride_length) AS avg_ride_length,
FROM `smooth-guru-386204.google_case_study_1.Divvy_Trips_Clean`
WHERE usertype = 'Customer'
  AND day_of_week != 1
  AND day_of_week != 7

-- Customer average weekday ride length = 61.7 mins

-- Average ride length for customers on weekends
SELECT
  AVG(ride_length) AS avg_ride_length,
FROM `smooth-guru-386204.google_case_study_1.Divvy_Trips_Clean`
WHERE usertype = 'Customer'
  AND day_of_week = 1
  OR day_of_week = 7

-- Customer average weekend ride length = 33.5 mins

-- Query to see max ride length for each customer type
SELECT
  usertype,
  MAX(ride_length) AS max_ride_length,
FROM `smooth-guru-386204.google_case_study_1.Divvy_Trips_Clean`
GROUP BY usertype

/*
usertype	max_ride_length
Subscriber	101607
Customer	177200

The ride length spanning several days likely means the user did not return
the vehicle correctly, probably does not represent the actual ride_length.
*/
