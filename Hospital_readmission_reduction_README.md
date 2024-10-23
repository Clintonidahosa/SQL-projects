# Hospital Readmission Data Analysis

## Project Overview
This project focuses on cleaning and analyzing hospital readmission data using SQL. The dataset contains information about hospital facilities, their readmission rates, and related metrics. The goal of this analysis is to uncover insights into hospital performance by processing the data, removing invalid entries, and exploring patterns in readmission rates.

## Usage
To replicate this analysis:
1. Use the SQL script in the `Hospital_readmission_reduction.sql` file.
2. Download the table - readmission.csv
3. Create a schema "Hosp_read" and import the "readmission" table to the schema
4. 4. Run the queries step by step for data cleaning and exploration.


## Key Steps
1. **Data Cleaning**: 
   - Removed invalid rows and handled missing data.
   - Ensured numeric columns and date formats were correctly defined.
   - Addressed negative values in key metrics.
   
2. **Data Exploration**:
   - Computed average readmission ratios and total discharges.
   - Filtered hospitals with high readmission rates and significant discharges.
   - Analyzed readmission trends over time.
   
3. **Data Validation & Optimization**:
   - Applied constraints and indexes to ensure data integrity and improve query performance.
   - Computed moving averages and running totals for smoother trend analysis.

## Queries Performed
- Aggregated data to get state-wise and facility-wise readmission statistics.
- Filtered data to identify hospitals with concerning readmission rates.
- Used window functions for cumulative totals and moving averages.
- Validated data integrity by setting constraints and adding indexes for optimization.

## Technologies Used
- **SQL**: For data cleaning, transformation, and exploratory analysis.

## Project Motivation
This analysis provides insight into hospital readmission trends and highlights facilities that may need performance improvements. It helps decision-makers focus on key areas for enhancing healthcare quality and reducing excess readmissions.



