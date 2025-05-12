--find top 10 highest reveue generating products 

select product_id, sum(sale_price) as revenue
from public.df_orders
group by 1
order by revenue desc
limit 10;


--find top 5 highest selling products in each region

with summ_sale_price_cte as
(
select region, product_id, sum(sale_price) as revenue
from public.df_orders
group by region, product_id
),
highest_sales_cte as 
(select 
*, dense_rank() over(partition by region order by revenue desc) as rnk
from summ_sale_price_cte)
select * from highest_sales_cte where rnk <= 5;


--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

with month_on_month_cte as
(
select extract(year from order_date) as order_year, 
extract(month from order_date) as order_month,
sum(sale_price) as sales
from public.df_orders
group by order_year, order_month
)
select 
order_month,
sum(case when order_year = '2022' then sales else 0 end) as sales_2022,
sum(case when order_year = '2023' then sales else 0 end) as sales_2023
from month_on_month_cte
group by order_month
order by order_month;


--for each category which month had highest sales 

WITH cte AS (
    SELECT 
        category,
        TO_CHAR(order_date, 'YYYYMM') AS order_year_month, -- format the date to 'YYYYMM'
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY category, order_year_month
)
SELECT * 
FROM (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) a
WHERE rn = 1;


--which sub category had highest growth by profit in 2023 compare to 2022

with month_on_month_cte as
(
select sub_category, 
extract(year from order_date) as order_year,
sum(sale_price) as sales
from public.df_orders
group by order_year, sub_category
),
cte2 as
(select 
sub_category,
sum(case when order_year = '2022' then sales else 0 end) as sales_2022,
sum(case when order_year = '2023' then sales else 0 end) as sales_2023
from month_on_month_cte
group by sub_category
)
select *
,((sales_2023-sales_2022)*100)/sales_2022 as percentage
from  cte2
order by ((sales_2023-sales_2022)*100)/sales_2022 desc
limit 1;









