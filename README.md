# Crop_Production_Analysis

# Project Overview

This project analyzes agricultural crop production data across states and districts in India using SQL and Power BI. The goal is to understand crop performance, production trends, and land-use efficiency (yield) through data-driven analysis and visualization.

# Objectives

Analyze crop production and yield efficiency

Identify top-performing crops and states

Study year-over-year and seasonal production trends

Present insights using interactive dashboards

# Project Structure
1. Database Setup

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
