# Crop_Production_Analysis

# Project Overview

This project analyzes agricultural crop production data across states and districts in India using SQL and Power BI. The goal is to understand crop performance, production trends, and land-use efficiency (yield) through data-driven analysis and visualization.

# Objectives

* Analyze crop production and yield efficiency
* Identify top-performing crops and states
* Study year-over-year and seasonal production trends
* Present insights using interactive dashboards

# Project Structure

### 1. Database Setup

Created a structured database to store agricultural data including state, district, crop year, season, crop type, cultivated area, and production quantity.
```sql
CREATE TABLE Crop_Data (
    State_Name VARCHAR(50),
    District_Name VARCHAR(50),
    Crop_Year INT,
    Season VARCHAR(20),
    Crop VARCHAR(50),
    Area FLOAT,
    Production FLOAT
);
```
### Using bulk insert method for Importing data.
```sql

bulk insert Agriculture
from 'C:\Users\mdadi\Downloads\Business Analyst Projects\Crop_prod_study Dataset-LB.csv'
	 with (
	       firstrow=2,
		   fieldterminator=',',
		   rowterminator='\n'
          )
```
### 2. Data Exploration & Cleaning

* Checked record counts and unique values
* Identified and handled null values in area and production fields
* Prepared clean data for accurate yield and trend analysis

```sql
select count(*) from Agriculture     -- 246091
select distinct state_name from Agriculture  -- 33 
select distinct crop from Agriculture  -- 124

SELECT *
FROM Agriculture
WHERE Area IS NULL OR Production IS NULL;
```

### 3. Data Analysis & Findings

* Calculated crop yield (Production / Area)
* Analyzed year-over-year growth by crop and state
* Identified high-yield crops and top-producing states
* Analyzed season-wise production trends
* Top Crops by Total Production
* Identify Low-Yield Districts
* Season-Wise Contribution

The following SQL queries were developed to answer specific business questions:

1. **Crop Yield Calculation (production per unit area)**:
```sql
SELECT
    State_Name,
    Crop,
    SUM(Production) / NULLIF(SUM(Area), 0) AS Avg_Yield
FROM Crop_Data
GROUP BY State_Name, Crop;

```

2. **Year-over-Year (YoY) Production Growth**:
```sql
With Yearly as (
select State_Name,
       Crop,
	   Crop_Year,
	   sum(Production) as 'Total_Production'
from Agriculture
group by state_name, Crop, Crop_Year
),

Growth as
(
select State_Name,
       Crop,
	   Crop_Year,
	   Total_Production,
	   Lag(Total_Production) over (partition by state_name, crop  order by crop_year) as 'Prev_year_production'
from Yearly 
)
select State_Name,
       Crop,
	   Crop_Year,
	   Total_Production,
	   Prev_year_production,
	   round((Total_Production - Prev_year_production),2) as 'Difference_in_Growth',
	   format((Total_Production - Prev_year_production) / nullif(Prev_year_production,0) * 100,'n2')+' %'
	   as 'YoY_Growth_Percentage'
from Growth
```

3. **Top N States by Average Yield**:
```sql
select top 5 state_name,
             Crop,
			 Crop_Year,
			 round(Avg(Production/ nullif(area,0)),2) as 'Avg_State_Yield'
from Agriculture
group by state_name, 
         crop,
		 Crop_Year
order by Avg_State_Yield desc
```

4. **States with Largest Increase in Cultivated Area for a Crop (Between Two Years).**:
```sql
With Area_by_Year as 
(
select State_name,
       Crop,
	   Crop_year,
	   sum(Area) as 'Total_Area'
from Agriculture
where crop = 'Rice'
group by State_Name,
         Crop,
		 Crop_Year
),

Pivoted as 
(
select State_Name,
       Crop,
       max(case when Crop_Year = 2000 then Total_Area End) as 'Area_2000',
	   max(case when Crop_Year = 2010 then Total_Area End) as 'Area_2010'
from Area_by_Year
group by State_Name,
         Crop
)
select State_Name,
       Crop,
	   Area_2000,
	   Area_2010,
	   (Area_2010 - Area_2000) as 'Increse_in_Area'
from Pivoted
order by Increse_in_Area Desc
```

5. **Top Crops by Total Production.**:
```sql
select State_Name,
       Crop,
	   season,
	   sum(Production) as 'Total_Production'
from Agriculture
group by State_Name,
         Crop, Season
order by Total_Production desc
```

6. **Identify Low-Yield Districts.**:
```sql
select State_Name,
       District_Name,
	   avg(production / nullif(area,0)) as 'Avg_Yield'
from Agriculture
group by State_Name, District_Name
order by Avg_Yield
```

7. **Season-Wise Contribution**:
```sql
select State_Name,
       Crop,
	   Season,
	   sum(production) as 'Total_Production'
from Agriculture
group by State_Name, Crop, Season
order by Total_Production desc
```

## Findings

* Crop production varies significantly across states and regions
* Certain crops demonstrate consistently higher yield efficiency
* Seasonal patterns (Kharif, Rabi, Whole Year) strongly influence production levels
* Some states show steady year-over-year growth, while others display fluctuations
* Yield analysis highlights regions with better land utilization

## Reports

* Production Summary: State-wise and crop-wise total production analysis
* Yield Analysis: Comparison of yield efficiency across crops and regions
* Trend Analysis: Year-over-year and season-wise production trends
* Geographic Insights: Regional performance using map-based visuals in Power BI

## Conclusion

This project demonstrates the ability to use SQL and Power BI to analyze real-world agricultural data, derive meaningful insights, and present findings through interactive dashboards. It highlights strong analytical and problem-solving skills relevant to Business Analyst and Data Analyst roles.





## Power BI Dashboard – Crop Production & Yield Analysis

## Project Overview

This Power BI dashboard visualizes crop production and yield data across states and crops in India, helping identify performance trends, yield efficiency, and seasonal patterns.

## Project Objectives

* Analyze state-wise and crop-wise production
* Compare yield efficiency across regions
* Understand year-wise and seasonal trends

## Dashboard Highlights

* KPIs for production, area, and yield
* State-wise production comparison
* Crop-wise yield analysis
* Year-wise and season-wise trends
* Interactive filters for State, Crop, Year, and Season

## Conclusion

The dashboard converts SQL-based analysis into interactive visuals, enabling quick insights and data-driven decision-making.

## Author
Mohamed Adilshahi – Aspiring Business Analyst

GitHub: https://github.com/mohamedadilshahi


Dashboard overview: https://github.com/mohamedadilshahi/Crop_Production_Analysis/blob/main/Dashboard.png
























