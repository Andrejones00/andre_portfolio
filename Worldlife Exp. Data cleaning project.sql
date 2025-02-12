-- Imported dataset twice, one as a back up and the other for data cleaning

select * 
from world_life_expectancy;

# removing duplicates using a subquery

select country, year, concat(country,year), count(concat(country,year)) 
from world_life_expectancy
group by country, year, concat(country,year)
having count(concat(country,year)) > 1 ;


select *														
from	(select row_id,
		concat(country,year),
		row_number() over(partition by concat(country,year) order by concat(country,year)) as row_num 
		from world_life_expectancy) as row_table
where row_num > 1; 

delete from world_life_expectancy
where row_id in (
		select row_id														
		from (select row_id,
		concat(country,year),
		row_number() over(partition by concat(country,year) order by concat(country,year)) as row_num 
		from world_life_expectancy) as row_table
where row_num > 1)
;

-- checking work

select country, year, concat(country,year), count(concat(country,year)) 
from world_life_expectancy
group by country, year, concat(country,year)
having count(concat(country,year)) > 1;

# missing data, taking data from populated data and inputing into blanks

select *
from world_life_expectancy
where status = ''
;

select distinct(status) 		#either going to be Developing or Developed
from world_life_expectancy
where status != ''
;

select distinct(country) 		#these couuntries that are developing
from world_life_expectancy
where status = 'Developing';

-- using a self join and updating from there
                
update world_life_expectancy t1    				
join world_life_expectancy t2
	on t1.country = t2.country
set t1.Status = 'Developing'
where t1.Status = ''
and t2.Status != ''
and t2.Status = 'Developing';

-- checking work

select *						-- found that only one country remaining, most likely Developed
from world_life_expectancy
where status = ''
;

select distinct(country) 		-- these couuntries that are developed
from world_life_expectancy
where status = 'Developed';

-- using a self join and updating from there

update world_life_expectancy t1    				
join world_life_expectancy t2
	on t1.country = t2.country
set t1.Status = 'Developed'
where t1.Status = ''
and t2.Status != ''
and t2.Status = 'Developed';

# checking work

select *						
from world_life_expectancy
where status = ''
;

select *						
from world_life_expectancy;

select *						
from world_life_expectancy
where `Life expectancy` = '';

-- based off the data it seems that life expectancy has been increasing over time, 
-- so we could input the average between previous and following year

select `Life expectancy`			
from world_life_expectancy;			

select country, year, `Life expectancy`						
from world_life_expectancy
where `Life expectancy` = '';

select t1.country, t1.year, t1.`Life expectancy`, 
t2.country, t2.year, t2.`Life expectancy`,
t3.country, t3.year, t3.`Life expectancy`,
round((t2.`Life expectancy` + t3.`Life expectancy`)/2,1) 	
from world_life_expectancy t1
join world_life_expectancy t2
	on t1.Country = t2.Country
    and t1.Year = t2.Year - 1
join world_life_expectancy t3
	on t1.Country = t3.Country
    and t1.Year = t3.Year + 1
where t1.`Life expectancy` = '';

update world_life_expectancy t1
join world_life_expectancy t2
	on t1.Country = t2.Country
    and t1.Year = t2.Year - 1
join world_life_expectancy t3
	on t1.Country = t3.Country
    and t1.Year = t3.Year + 1
set t1.`Life expectancy` = round((t2.`Life expectancy` + t3.`Life expectancy`)/2,1) 	
where t1.`Life expectancy` = '';

# checking work		

select *, country, year, `Life expectancy`			
from world_life_expectancy
where `Life expectancy` = '';

select *
from world_life_expectancy;