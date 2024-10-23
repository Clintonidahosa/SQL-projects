# Layoffs Data Cleaning and Exploration

This project focuses on cleaning and analyzing global layoffs data, including details like company, industry, location, number of layoffs, and company stage. The goal is to remove duplicates, standardize data, and explore trends over time.

## Objectives
- **Data Cleaning**:
  - Remove duplicates using row numbering.
  - Standardize text fields and format dates.
  - Handle missing values and remove irrelevant columns/rows.

- **Data Exploration**:
  - Analyze layoffs by company, industry, and country.
  - Identify top companies with the highest layoffs per year.
  - Explore monthly layoff trends and rolling totals.

## Dataset
Key columns:
- `company`, `location`, `industry`, `total_laid_off`, `percentage_laid_off`, `date`, `stage`, `country`, `funds_raised`

## Key SQL Steps
1. **Duplicate Removal**: Using `ROW_NUMBER()` to identify and delete redundant records.
2. **Data Standardization**: Trimming spaces and converting `date` fields.
3. **Exploration**: Summarizing layoffs by company, industry, year, and country, and computing rolling totals.

## Results
- Identified top companies by layoffs and observed industry-specific trends.
- Found spikes in layoffs by month and year, with insights on country and industry distributions.

## Tools
- **SQL**: For data cleaning and querying.
- **MySQL**: Database used for this project.

## How to Use
- Clone the repository.
- Run the SQL scripts provided in a MySQL environment.

## Future Work
- Add data visualizations in Tableau or Power BI.
- Explore predictive modeling on layoff trends.
