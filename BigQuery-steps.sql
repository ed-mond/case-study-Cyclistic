/* Queries used in BigQuery to analyze dataset */

-- Join the two datasets into one single dataset
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

