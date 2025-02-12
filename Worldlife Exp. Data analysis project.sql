# Exploratory Data Analysis

select *
from world_life_expectancy;

# how has each country done from 2007 to 2022 in terms of life expectancy

select Country, min(`Life expectancy`) min, max(`Life expectancy`) max		
from world_life_expectancy
group by country					-- we found some countries has zero in both min and max
having min != 0 and max != 0
order by country desc;

# which country made the biggest strides over the last 15 years in life expectancy growth and growth in GDP

select Country, 
min(`Life expectancy`) min, 
max(`Life expectancy`) max,
round(max(`Life expectancy`) - min(`Life expectancy`),1) as life_increase_over_15_years,
min(GDP) mingdp, 
max(GDP) maxgdp,
round(max(GDP) - min(GDP),1) AS GDP_increase
from world_life_expectancy
group by country					
having min != 0 and max != 0 and maxgdp!= 0 and mingdp != 0
order by life_increase_over_15_years desc;


# seeing correlation between life expectancy and GDP

select country, round(avg(`Life expectancy`),2) as Life_exp, round(avg(GDP),1) as GDP
from world_life_expectancy
group by country
having Life_exp > 0
and GDP > 0
order by GDP asc;

# countries with lower GDP tend to correlate to higher life expectancy at first glance

