SELECT * FROM public.netflix_raw;

-- 1. remove duplicates 

-- Check on the basis of "show_id" column, there is no duplicates
SELECT show_id, count(*) 
FROM public.netflix_raw
group by show_id
having count(*) > 1;

-- Check on the basis of "title" column, there are no duplicates
SELECT upper(title), count(*) 
FROM public.netflix_raw
group by upper(title)
having count(*) > 1;

-- Breakdown the Analysis
select * from public.netflix_raw
where upper(title) in (
select upper(title) from public.netflix_raw
group by upper(title)
having COUNT(*)>1
)
order by title

--
select * from public.netflix_raw
where concat(upper(title), type) in (
select concat(upper(title), type) from public.netflix_raw
group by upper(title), type
having COUNT(*)>1
)
order by title

-- Handling the duplicate rows
with cte as
(
select *, row_number() over(partition by upper(title), type order by show_id) as rn
from public.netflix_raw
)
select * from cte where rn = 1;


-- 2. New table for listed_in, director, country, cast

-- Way of splitting a single row into multiple rows
SELECT 
show_id, trim(value) AS director
FROM public.netflix_raw,
LATERAL unnest(string_to_array(director, ',')) AS value;

-- Explanation:
-- string_to_array(director, ','): splits the director string by comma into an array
-- unnest(...): expands the array into multiple rows
-- LATERAL: allows unnest to reference the director column from netflix_raw
-- trim(value): removes leading/trailing spaces from each name


-- Create netflix_director table using netflix_raw table
SELECT 
show_id, trim(value) AS director
into public.netflix_director
FROM public.netflix_raw,
LATERAL unnest(string_to_array(director, ',')) AS value;

-- Similaly, need to create for listed_in, country, cast
-- for listed_in column
SELECT 
show_id, trim(value) AS genre
into public.netflix_genre
FROM public.netflix_raw,
LATERAL unnest(string_to_array(listed_in, ',')) AS value;

-- for country column
SELECT 
show_id, trim(value) AS country
into public.netflix_country
FROM public.netflix_raw,
LATERAL unnest(string_to_array(country, ',')) AS value;

-- for cast column
SELECT 
show_id, trim(value) AS "cast"
into public.netflix_cast
FROM public.netflix_raw,
LATERAL unnest(string_to_array("cast", ',')) AS value;

-- Validate
SELECT * FROM public.netflix_director;
SELECT * FROM public.netflix_genre;
SELECT * FROM public.netflix_country;
SELECT * FROM public.netflix_cast;



-- 3. Data type conversions for date added 

select show_id, cast(date_added as date)
from public.netflix_raw;


-- 4. Populate missing values in the country, duration columns

-- For country column
insert into public.netflix_country
select  show_id, m.country 
from public.netflix_raw nr
inner join (
select director,country
from public.netflix_country nc
inner join public.netflix_director nd on nc.show_id = nd.show_id
group by director, country
) m on nr.director = m.director
where nr.country is null;

select * from public.netflix_raw where director='Ahishor Solomon'

select director, country
from public.netflix_country nc
inner join public.netflix_director nd on nc.show_id = nd.show_id
group by director, country;


-- For duration column
select * from public.netflix_raw where duration is null



-- Create final Netflix table for Analysis after data cleaning
with cte as 
(
select * 
,ROW_NUMBER() over(partition by title , type order by show_id) as rn
from netflix_raw
)
select show_id, type, title, cast(date_added as date) as date_added, release_year, rating, 
case when duration is null then rating else duration end as duration, description
into public.netflix
from cte;


-- Final Tables
SELECT * FROM public.netflix;
SELECT * FROM public.netflix_director;
SELECT * FROM public.netflix_genre;
SELECT * FROM public.netflix_country;
SELECT * FROM public.netflix_cast;