--netflix data analysis

-- Final Tables
SELECT * FROM public.netflix;
SELECT * FROM public.netflix_director;
SELECT * FROM public.netflix_genre;
SELECT * FROM public.netflix_country;
SELECT * FROM public.netflix_cast;


/*1  for each director count the no of movies and tv shows created by them in separate columns 
for directors who have created tv shows and movies both */

select t2.director,
-- sum(case when t1.type = 'Movie' then 1 else 0 end) as no_of_movies,
-- sum(case when t1.type = 'TV Show' then 1 else 0 end) as no_of_tv_shows
-- OR
count(case when t1.type = 'Movie' then t1.show_id end) as no_of_movies,
count(case when t1.type = 'TV Show' then t1.show_id end) as no_of_tv_shows
from netflix as t1
join netflix_director as t2
on t1.show_id = t2.show_id
group by t2.director
having count(distinct t1.type) > 1;



--2 which country has highest number of comedy movies 

SELECT t2.country, count(t1.show_id) as no_of_comedy_movies
FROM public.netflix_genre as t1
join public.netflix_country as t2
on t1.show_id = t2.show_id
join public.netflix as t3
on t2.show_id = t3.show_id
where t1.genre ilike '%comedies%' and t3.type = 'Movie'
group by t2.country
order by no_of_comedy_movies desc
limit 1;



--3 for each year (as per date added to netflix), which director has maximum number of movies released

with movie_cnt_cte as
(
select 
extract(year from t1.date_added) as year, t2.director, count(t1.show_id) as no_of_movies
from netflix as t1
join netflix_director as t2
on t1.show_id = t2.show_id
where t1.type = 'Movie'
group by 1, 2
),
rnk_cte as
(select 
year, director, no_of_movies,
row_number() over(partition by year order by no_of_movies desc, director) as rnk
from movie_cnt_cte
)
select year, director, no_of_movies from rnk_cte where rnk = 1;



--4 what is average duration of movies in each genre

select t2.genre, round(avg(cast(replace(t1.duration, 'min', '') as int)), 2) as avg_duration
from netflix as t1
join netflix_genre as t2
on t1.show_id = t2.show_id
where t1.type = 'Movie'
group by 1;



--5  find the list of directors who have created horror and comedy movies both.
-- display director names along with number of comedy and horror movies directed by them 

select t3.director
, count(distinct case when t2.genre='Comedies' then t1.show_id end) as no_of_comedy 
, count(distinct case when t2.genre='Horror Movies' then t1.show_id end) as no_of_horror
from netflix t1
inner join netflix_genre t2 on t1.show_id = t2.show_id
inner join netflix_director t3 on t1.show_id = t3.show_id
where type='Movie' and t2.genre in ('Comedies','Horror Movies')
group by t3.director
having COUNT(distinct t2.genre)=2;



-- Validation

select * from netflix_genre
where show_id in (select show_id from netflix_director where director = 'Banjong Pisanthanakun')
order by genre;