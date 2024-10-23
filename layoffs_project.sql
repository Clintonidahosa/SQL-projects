-- # DATA CLEANING 

-- Step 1: View the original layoffs data
SELECT *
FROM layoffs;

-- Step 2: Create a staging table that is a copy of the original layoffs table
CREATE TABLE layoffs_staging
LIKE layoffs;

-- Step 3: View the structure of the staging table to confirm the creation
SELECT *
FROM layoffs_staging;

-- Step 4: Insert data from the original table into the staging table for cleaning
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- Step 5: Verify data has been inserted into the staging table
SELECT *
FROM layoffs_staging;

-- Step 6: Add row numbers to identify duplicate rows based on unique fields
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

-- Step 7: Using CTE to identify duplicates by assigning row numbers to similar rows
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1; -- Shows duplicates (rows with row_num > 1)

-- Step 8: Create a new table to store the clean data after removing duplicates
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` double DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Step 9: View the structure of the second staging table
SELECT *
FROM layoffs_staging2;

-- Step 10: Insert data into the new table and assign row numbers for duplicate identification
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
FROM layoffs_staging;

-- Step 11: Identify rows with duplicate data (row_num > 1)
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Step 12: Disable safe updates to allow deletion of rows
SET SQL_SAFE_UPDATES = 0;

-- Step 13: Delete duplicate rows (rows where row_num > 1)
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

-- Step 14: Verify the table after deleting duplicates
SELECT *
FROM layoffs_staging2;

-- Step 15: Remove leading/trailing spaces from the company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Step 16: Convert date strings into a proper date format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%Y-%m-%d');

-- Step 17: Alter the column to change the datatype to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Step 18: Remove unnecessary rows where key columns have missing data
DELETE
FROM layoffs_staging2
WHERE total_laid_off = ''
AND percentage_laid_off = '';

-- Step 19: Drop the row_num column after cleaning
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- # DATA EXPLORATION

-- Step 20: View cleaned data in the staging table
SELECT *
FROM layoffs_staging2;

-- Step 21: Calculate total layoffs by each company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC;

-- Step 22: Analyze total layoffs per year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY YEAR(`date`);

-- Step 23: Calculate total layoffs by industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC;

-- Step 24: Summarize total layoffs and funds raised by country
SELECT country, SUM(total_laid_off), SUM(funds_raised)
FROM layoffs_staging2
GROUP BY country 
ORDER BY SUM(total_laid_off) DESC;

-- Step 25: Summarize layoffs by company stage and total funds raised
SELECT stage, SUM(total_laid_off), SUM(funds_raised)
FROM layoffs_staging2
GROUP BY stage
ORDER BY stage;

-- Step 26: Find the maximum layoffs per year
SELECT YEAR(`date`), MAX(total_laid_off) 
FROM layoffs_staging2
GROUP BY YEAR (`date`)
ORDER BY YEAR (`date`);

-- Step 27: Summarize layoffs by month and total laid off
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY `MONTH`
ORDER BY `MONTH` ASC;

-- Step 28: Calculate the rolling total of layoffs month by month
WITH Rolling_total_table AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY `MONTH`
ORDER BY `MONTH` ASC
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS Rolling_Total
FROM Rolling_total_table;

-- Step 29: Using CTEs to get the top 5 companies that laid off the most workers each year
WITH Company_Rank AS
(
SELECT company, YEAR(`date`) AS `Year`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY company, `Year`
ORDER BY `Year` ASC
), 
TOP_5_COMPANIES AS
(
SELECT *,
DENSE_RANK() OVER (PARTITION BY `Year`ORDER BY total_off DESC) AS Ranking
FROM Company_Rank
)
SELECT *
FROM TOP_5_COMPANIES
WHERE Ranking < 6;

-- Step 30: Another method to get top 5 companies by layoffs each year using CTEs
WITH Top_5_companies AS
(
SELECT company, 
YEAR(`date`) AS `Year`, 
SUM(total_laid_off) AS total_off,
DENSE_RANK() OVER(PARTITION BY YEAR(`date`) ORDER BY SUM(total_laid_off) DESC ) AS Ranking
FROM layoffs_staging2
GROUP BY company, `Year`
)
SELECT *
FROM Top_5_companies
WHERE Ranking < 6;
