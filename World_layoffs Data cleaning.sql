-- Data Cleaning

select *
from layoffs
;

-- 1. Remove Dupilcates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove Any Columns

## Its a best practice to create a new table just in case any mistakes are made that you dont impact the original data (real world situation)

-- I start by creating a new staging table similar to layoffs in order to obtain all the columns from the original table 

create table layoffs_staging
like layoffs
;

select *
from layoffs_staging
;

-- Insert all the orignal data into the new staging table

insert layoffs_staging
select *
from layoffs
;

-- check work

select * 
from layoffs_staging
;

-- 1. Remove Duplicates

select *
from layoffs_staging;

-- Im noticing there no column unique row id
-- using row_number and paritioning by all the columns in order to idenifty any duplicate rows
-- Since row_num creates a unique ID for each row, any row_num that is greater than 1 should be deleted from table

select *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
;

-- Using a CTE in order to idenifty rows with row_num greater than 1


with duplicate_cte as
(
select *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;

-- need to create a new staging table to identify the row_num and the delete it the duplicates from the staging table that have row_num > 1

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_staging2;

insert into layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
;

-- test/check

select * 
from layoffs_staging2;

-- we must delete the rows where the column "row_num" is greater than 1

select * 
from layoffs_staging2
where row_num > 1;

delete 
from layoffs_staging2
where row_num > 1;

 -- test/check
 
select *
from layoffs_staging2
where row_num > 1;

select *
from layoffs_staging2;

-- 2. Standardizing Data
-- its good to check all the columns and scan through them all to see any possible issues

select company, trim(company)
from layoffs_staging2
;

update layoffs_staging2
set company = trim(company)
;

select distinct industry
from layoffs_staging2
order by 1;

-- getting rid of cryptocurrency and changing it with crypto

select *    
from layoffs_staging2
where industry like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

-- checking work

select distinct industry 
from layoffs_staging2;

select distinct country
from layoffs_staging2
where country like 'United States%';

-- using Trim() and trailing to get rid of the trailing period on the United States

select distinct country, trim(trailing '.' from country) 
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

-- checking work

select distinct country 
from layoffs_staging2
order by 1;

 -- chanigng dates from text to date for the column
 
select `date`,
str_to_date(`date`, '%m/%d/%Y') -- '%m/%d/%Y' is the date format
from layoffs_staging2;

update layoffs_staging2 -- fixing to the correct date format
set `date` = str_to_date(`date`, '%m/%d/%Y');

-- checking work

select `date` 
from layoffs_staging2;

-- now changing from 'text' column to a 'date' column'

alter table layoffs_staging2 
modify column `date` date; 

-- checkig work

select * 
from layoffs_staging2;


-- 3. NULL AND BLANK VALUES
-- need to change blanks for the Nulls

update layoffs_staging2 
set industry = null
where industry = '';

select *
from layoffs_staging2
where industry is null
or industry = '';

-- need to input travel into the blank one

select * 
from layoffs_staging2
where company = 'Airbnb';

-- self join to replace the nulls with the correct industry

select *
from layoffs_staging2 as t1
join layoffs_staging2 as t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null
;


select t1.industry, t2.industry 
from layoffs_staging2 as t1
join layoffs_staging2 as t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null
;

-- replacing the Nulls with there travel, transportation, or consumer counterpart

update layoffs_staging2 as t1 
join layoffs_staging2 as t2
	on t1.company = t2.company
set t1.industry = t2.industry 
where t1.industry is null 
and t2.industry is not null;

-- checking work to confirm industry is blank

select t1.industry, t2.industry 
from layoffs_staging2 as t1
join layoffs_staging2 as t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null
;
-- checking to see if airbnb was poplulated

select * 
from layoffs_staging2
where company = 'Airbnb';

-- 4. REMOVING COLUMNS AND ROWS

-- since total_laid_off and percantage_laid_off is null is basically usesless for the this analysis 

select * 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- checking work

select *  
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- getting rid of the "row_num" column

alter table layoffs_staging2 -- getting rid of the "row_num" column
drop column row_num;

 -- checking work
 
select *
from layoffs_staging2;