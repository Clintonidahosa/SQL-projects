-- Step 1: Duplicate the table for backup purposes
-- This part ensures you have a backup of the table before making any changes
CREATE TABLE hosp_read.readmission_backup AS
SELECT * FROM hosp_read.readmission;

-- Data Inspection: Verify if the table has been duplicated correctly by counting rows
SELECT COUNT(*) AS row_count FROM hosp_read.readmission_backup;

-- Step 2: Remove rows where critical columns have 'N/A' or null values
-- This part cleans up invalid or missing data to ensure consistency
DELETE FROM hosp_read.readmission
WHERE `Facility Name` IS NULL
   OR `Facility ID` IS NULL
   OR `Excess Readmission Ratio` = 'N/A'
   OR `Excess Readmission Ratio` IS NULL
   OR `Predicted Readmission Rate` = 'N/A'
   OR `Expected Readmission Rate` = 'N/A'
   OR `Number of Readmissions` = 'Too Few to Report';

-- Data Cleaning: Convert 'N/A' in 'Number of Discharges' to NULL for accurate numeric processing
UPDATE hosp_read.readmission
SET `Number of Discharges` = NULL
WHERE `Number of Discharges` = 'N/A';

-- Ensure the date columns have consistent formatting
-- This part standardizes the date format for future analysis
UPDATE hosp_read.readmission
SET `Start Date` = STR_TO_DATE(`Start Date`, '%m/%d/%Y'),
    `End Date` = STR_TO_DATE(`End Date`, '%m/%d/%Y');

-- Step 3: Modify the schema to change data types (if needed)
-- This ensures the columns have the correct data types for numerical operations
ALTER TABLE hosp_read.readmission
MODIFY `Excess Readmission Ratio` DECIMAL(5, 4),
MODIFY `Predicted Readmission Rate` DECIMAL(6, 4),
MODIFY `Expected Readmission Rate` DECIMAL(6, 4),
MODIFY `Number of Readmissions` INT,
MODIFY `Number of Discharges` INT;

-- Step 4: Set negative values to NULL for readmission-related columns
-- This step addresses invalid negative values in key metrics
UPDATE hosp_read.readmission
SET `Excess Readmission Ratio` = NULL
WHERE `Excess Readmission Ratio` < 0;

UPDATE hosp_read.readmission
SET `Predicted Readmission Rate` = NULL
WHERE `Predicted Readmission Rate` < 0;

UPDATE hosp_read.readmission
SET `Expected Readmission Rate` = NULL
WHERE `Expected Readmission Rate` < 0;

-- Step 5: Data Exploration - Get the average readmission rate and discharge count for each state and facility
-- This is an exploratory query to understand the data by computing averages and totals
SELECT `State`, `Facility Name`,
       AVG(`Excess Readmission Ratio`) AS avg_readmission_ratio,
       SUM(`Number of Discharges`) AS total_discharges
FROM hosp_read.readmission
GROUP BY `State`, `Facility Name`
ORDER BY avg_readmission_ratio DESC;

-- Step 6: Data Exploration - Filter hospitals with readmission ratio above 1.0 and more than 500 discharges
-- Further exploration to identify hospitals with higher-than-average readmission ratios
SELECT `Facility Name`, `State`, `Excess Readmission Ratio`, `Number of Discharges`
FROM hosp_read.readmission
WHERE `Excess Readmission Ratio` > 1.0
  AND `Number of Discharges` > 500
ORDER BY `Excess Readmission Ratio` DESC;

-- Step 7: Data Inspection - Filter records based on the reporting date range
-- This query ensures that the date range is within the specified bounds for analysis
SELECT `Facility Name`, `State`, `Start Date`, `End Date`
FROM hosp_read.readmission
WHERE `Start Date` >= '2019-01-01' AND `End Date` <= '2022-12-31';

-- Step 8: Data Exploration - Find hospitals with readmission ratios higher than the state average
-- This subquery compares each hospital's readmission ratio to the state average
SELECT `Facility Name`, `State`, `Excess Readmission Ratio`
FROM hosp_read.readmission r
WHERE `Excess Readmission Ratio` > (
    SELECT AVG(`Excess Readmission Ratio`)
    FROM hosp_read.readmission
    WHERE `State` = r.`State`
);

-- Step 9: Data Exploration - Compute a running total of discharges per state
-- This query computes a running total of discharges for each state
SELECT `State`, `Facility Name`, `Number of Discharges`,
       SUM(`Number of Discharges`) OVER (PARTITION BY `State` ORDER BY `Number of Discharges`) AS running_total_discharges
FROM hosp_read.readmission;

-- Step 10: Data Exploration - Compute moving average of Excess Readmission Ratio for each state
-- This query computes a moving average of the readmission ratio within a state
SELECT `Facility Name`, `State`, `Excess Readmission Ratio`,
       AVG(`Excess Readmission Ratio`) OVER (PARTITION BY `State` ORDER BY `Excess Readmission Ratio` ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS moving_avg_ratio
FROM hosp_read.readmission;

-- Step 11: Create indexes on common search columns
-- Adding indexes to improve query performance, especially on columns frequently used in WHERE or JOIN clauses
CREATE INDEX idx_state ON hosp_read.readmission(`State`(10));
CREATE INDEX idx_readmission_ratio ON hosp_read.readmission(`Excess Readmission Ratio`);

-- Step 12: Add constraints to ensure valid data in critical columns
-- This part ensures that key columns only contain non-negative values
ALTER TABLE hosp_read.readmission
ADD CONSTRAINT chk_readmission_ratio CHECK (`Excess Readmission Ratio` >= 0),
ADD CONSTRAINT chk_predicted_rate CHECK (`Predicted Readmission Rate` >= 0),
ADD CONSTRAINT chk_expected_rate CHECK (`Expected Readmission Rate` >= 0);

-- Step 13: Data Exploration - Calculate average readmission ratio per year based on the 'Start Date'
-- Exploring readmission trends over the years by calculating yearly averages
SELECT YEAR(`Start Date`) AS year, AVG(`Excess Readmission Ratio`) AS avg_readmission_ratio
FROM hosp_read.readmission
GROUP BY year
ORDER BY year;

-- Step 14: Data Exploration - Summary report of hospitals with the highest average readmission ratios per state
-- This query retrieves the top 10 hospitals with the highest average readmission ratios
SELECT `State`, `Facility Name`, AVG(`Excess Readmission Ratio`) AS avg_readmission_ratio
FROM hosp_read.readmission
GROUP BY `State`, `Facility Name`
ORDER BY avg_readmission_ratio DESC
LIMIT 10;

-- Step 15: Data Exploration - Report on hospitals with readmission ratios higher than the national average
-- Comparing hospitals to the national average readmission ratio
SELECT `Facility Name`, `State`, `Excess Readmission Ratio`
FROM hosp_read.readmission
WHERE `Excess Readmission Ratio` > (SELECT AVG(`Excess Readmission Ratio`) FROM hosp_read.readmission);
