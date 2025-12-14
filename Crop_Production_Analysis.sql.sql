
-- Crop Production and Yield Analysis


/*

1. Project Overview

  Problem Statement

Agriculture is one of India’s largest sectors, and decision-making heavily depends on understanding crop performance,
yield efficiency, and long-term trends. This project analyzes crop production data across Indian states and districts
to extract meaningful insights using SQL.

2. Project Objectives

#. Calculate crop yield (Production ÷ Area) and identify the most efficient crops.
#. Analyze year-over-year (YoY) crop production growth for each state.
#. Identify top N states with the highest average yield.
#. Find states showing the largest increase in cultivation area for a given crop between two selected years.

(Optional) Prepare insights for visualization in Power BI/Tableau.

3. Dataset Description (Columns)

  Column Name	Description

#. State_Name	    State where crop is grown
#. District_Name	District within state
#. Crop_Year	    Year of production
#. Season	        Season of cultivation
#. Crop	            Crop type
#. Area	            Area cultivated (hectares)
#. Production	    Total production (metric tons)
*/

/*
  Insight we have do in SQL

1. Calculate crop yield (production per unit area) to assess which crops are the most efficient in production.
2. Calculates the year-over-year percentage growth in crop production for each state and crop.
3. Calculates each state's average yield (production per area) and identifies the top N states with the highest
   average yield over multiple years.
4. Identifies states that have the largest increase in cultivated area for a specific crop between two years
*/



-- Create the database

Create database Crop_Production_and_Yield_Analysis

use Crop_Production_and_Yield_Analysis


-- Create table

create table Agriculture
(State_Name varchar(50), District_Name varchar(50),
Crop_Year Int, Season varchar(50),
Crop varchar(50), Area float,
Production float)

select * from Agriculture

-- Note: while creating table take the column names whatever present in the dataset (in excel csv.file), if any column name 
-- not matching what we have created in table, then the data will not import properly, for that make sure.

-- Using bulk insert method for Importing data.

bulk insert Agriculture
from 'C:\Users\mdadi\Downloads\Business Analyst Projects\Crop_prod_study Dataset-LB.csv'
      
	 with (
	       firstrow=2,
		   fieldterminator=',',
		   rowterminator='\n'
          )


/*
-- steps to bulk import the data from csv file

-- step 1 : create the table
--          the table header or column name should be same compare to the data set.

-- step 2 : write the bulk insert query

-- bulk insert "table_name (like agriculture) or production"
-- from 'provide the file address with file name and .csv'
                -(go to file where data is present -> right click -> show more option
                -> go to properties -> go location -> copy the address from there
				-> paste under the paranthesis
				-> C:\Users\mdadi\Downloads\Business Analyst Projects
				-> give file name after slash '\', 'Crop_prod_study Dataset-LB'
				-> .csv
   final address under parenthesis  'C:\Users\mdadi\Downloads\Business Analyst Projects\Crop_prod_study Dataset-LB.csv'



    with (
	       firstrow=2,      (it means we are going import data from 2nd row, in 1st row we have column names)
		   fieldterminator=',',  (Purpose: Specifies the character(s) that separate columns (fields) in your data file.)
		   rowterminator='\n'   (Purpose: Specifies the character(s) that separate rows (records) in your file.)
          )

*/


-- 4. Data Exploration & Cleaning


/*
* Checked record counts and unique values
* Identified and handled null values in area and production fields
* Prepared clean data for accurate yield and trend analysis
*/


select count(*) from Agriculture     -- 246091

select distinct state_name from Agriculture  -- 33 

select distinct crop from Agriculture  -- 124

SELECT *
FROM Agriculture
WHERE Area IS NULL OR Production IS NULL;



-- 5. SQL Insights + Full Explanation


-- 1: Crop Yield Calculation (production per unit area)
-- Goal: Identify which crops are most efficient in terms of production per hectare.
-- Formula

-- Yield = Production / Area

select Crop,
       avg(production/ nullif(area,0)) as 'Avg_yield_per_hectare'
from Agriculture
group by Crop  
order by Avg_yield_per_hectare desc

select * from Agriculture
/*
Explanation

#. Production / Area gives yield per hectare.
#. NULLIF(Area, 0) avoids division by zero.
#. AVG() gives overall yield for each crop across all years and states.
#. Ordering DESC shows most efficient crops at the top.

  (Coconut 4040.40356774497 highest Yield)
  
  What This Insight Tells

#. Crops with high yield require less land for the same output.
#. Helps identify efficient crops for future planning.
#. Useful for agricultural optimization and resource allocation.
*/



-- 2: Year-over-Year (YoY) Production Growth

-- Goal: See how crop production is changing year to year for each state & crop.

With Yearly as
(
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



/*
   Explanation

#. First, calculate total production per year (CTE yearly).
#. Use LAG() window function to get previous year’s production.
#. Calculate YoY Growth = (Current − Previous) / Previous * 100.
#. This shows production trend direction: increasing or decreasing.

What This Insight Tells

#. Identifies which states are improving or declining in crop production.
#. Helps detect crop failures or bumper years.
#. Useful for forecasting and policy decisions.
*/


-- 3: Top N States by Average Yield


-- Goal: Identify which states produce the most efficient crops overall.
-- Assume N = 5 (top 5 states).

select top 5 state_name,
             Crop,
			 Crop_Year,
			 round(Avg(Production/ nullif(area,0)),2) as 'Avg_State_Yield'
from Agriculture
group by state_name, 
         crop,
		 Crop_Year
order by Avg_State_Yield desc



/*
  Explanation

#. Computes average yield per state.
#. Sorts by efficiency.
#. Picks the top N states with highest agricultural performance.

 What This Insight Tells

#. Helps identify high-performing agricultural states.
#. Useful for benchmarking and comparing region-wise efficiency.
*/


-- 4: States with Largest Increase in Cultivated Area for a Crop (Between Two Years)

-- Example: Find states with highest area increase for Rice between 2000 and 2010.



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



/*
   Explanation

#. First aggregate total area by year for the selected crop.
#. Pivot 2000 and 2010 into columns.
#. Calculate difference.
#. Sort by areas with biggest increase.

What This Insight Tells

#. Shows which states expanded cultivation the most for a specific crop.
#. Useful for investment, irrigation planning, or land use changes.


*/



-- 5. Top Crops by Total Production

select State_Name,
       Crop,
	   season,
	   sum(Production) as 'Total_Production'
from Agriculture
group by State_Name,
         Crop, Season
order by Total_Production desc

-- 6. Identify Low-Yield Districts

select State_Name,
       District_Name,
	   avg(production / nullif(area,0)) as 'Avg_Yield'
from Agriculture
group by State_Name, District_Name
order by Avg_Yield

-- 7. Season-Wise Contribution

select State_Name,
       Crop,
	   Season,
	   sum(production) as 'Total_Production'
from Agriculture
group by State_Name, Crop, Season
order by Total_Production desc
