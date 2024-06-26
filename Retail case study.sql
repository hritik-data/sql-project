-- Data Preparation

--1 What is the total number of rows in each of the 3 tables in the database?
select 'Customer' as Table_Name ,COUNT(*) as Row_Num from Customer 
Union
select 'Product' , COUNT(*) as Row_Num_Product from prod_cat_info 
Union
select 'Transactions' , COUNT(*)  as Row_Num_Transactions from Transactions as Row_Num_Transactions

--2 What is the total number of transactions that have a return?

select Distinct COUNT(*) as No_of_tran from Transactions
where Qty<0;

--3.	As you would have noticed, the dates provided across the datasets are not in a correct format.
--As first steps, pls convert the date variables into valid date formats before proceeding ahead.

select Convert(Date,DOB,103) from Customer
select Convert(Date,tran_date,103) from Transactions

--4.	What is the time range of the transaction data available for analysis?
--Show the output in number of days, months and years simultaneously in different columns.


select DATEDIFF(DAY,Min(tran_date),Max(tran_date)) as _day, 
DATEDIFF(Month , Min(tran_date) , Max(tran_date)) as _Month,
DATEDIFF(YEAR , MIN(tran_date) , MAX(tran_date)) as _year from Transactions

-- 5.	Which product category does the sub-category “DIY” belong to?

select prod_cat from prod_cat_info
where prod_subcat = 'DIY'

--Data Analysis

-- 1.	Which channel is most frequently used for transactions?
--Ans E-shop

select top 1 Store_type, COUNT(transaction_id) as No_of_transactions from Transactions
group by Store_type
order by No_of_transactions desc

-- 2.	What is the count of Male and Female customers in the database?
--And Male - 2892 and Female 2753

select'Male' as _Gender ,  COUNT(*) as Count_Cust from Customer
where Gender = 'M'
Union
select'Female' ,  COUNT(*) from Customer
where Gender = 'F'


-- 3.	From which city do we have the maximum number of customers and how many?
--Ans City_code 3 , count - 595

select top 1 city_code ,  count(customer_Id) as Count_cust from Customer
group by city_code
order by Count_cust desc
 

  -- 4.	How many sub-categories are there under the Books category?
-- Ans 6 Subcategories

  select prod_cat , count(prod_subcat) as No_of_SubCat  from prod_cat_info
  where prod_cat = 'Books'
  group by prod_cat  


  
 

  --5.	What is the maximum quantity of products ever ordered?
-- Ans Books - 18151 

select  top 1 prod_cat, sum(abs(qty)) as Quantity from Transactions as T
join prod_cat_info as P
on T.prod_cat_code = P.prod_cat_code and T.prod_subcat_code = P.prod_sub_cat_code
group by prod_cat
order by Quantity desc


--6.	What is the net total revenue generated in categories Electronics and Books?
--Ans 23545157.67

select round(SUM(total_amt),2) as Net_Revenue from Transactions as T
join prod_cat_info as P
on T.prod_cat_code = P.prod_cat_code and T.prod_subcat_code = P.prod_sub_cat_code
where prod_cat in ('Electronics' , 'Books')


-- 7.	How many customers have >10 transactions with us, excluding returns? 
-- 6 customers

select  COUNT(customer_id) No_of_Customer from Customer 
where customer_Id in (select cust_id  from Transactions
where qty>0
group by cust_id
having COUNT(cust_id)>10 )



 -- 8.	What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?
-- Ans 3409559.27

select round(SUM(total_amt),2) as Total_revenue from Transactions as T
join prod_cat_info P 
on  P.prod_sub_cat_code = T.prod_subcat_code and T.prod_cat_code = P.prod_cat_code
where (prod_cat in ('Electronics' , 'Clothing')) and (Store_type = 'Flagship Store')



--9.	What is the total revenue generated from “Male” customers in “Electronics” category? Output should display total revenue by prod sub-cat.


select prod_subcat  ,round(SUM(total_amt),2) AS Total_revenue from Customer C
join Transactions T
on C.customer_Id = T.cust_id 
join prod_cat_info P on T.prod_cat_code = P.prod_cat_code and T.prod_subcat_code = P.prod_sub_cat_code
where Gender = 'M' and prod_cat = 'Electronics'
group by prod_subcat




-- 10.	What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?

select Y.prod_subcat , Perc_Sales ,Perc_Return from (
(select top 5  prod_subcat ,  SUM(total_amt)*100/(select SUM(total_amt)  from Transactions where total_amt>0 ) as Perc_Sales
FROM  Transactions as T
join prod_cat_info  as P on T.prod_cat_code = P.prod_cat_code and T.prod_subcat_code = P.prod_sub_cat_code
where total_amt >0
GROUP  BY prod_subcat
order by Perc_Sales desc
 ) as Z
left join 
(select prod_subcat ,  SUM(total_amt)*100/(select SUM(total_amt) from Transactions where total_amt<0 ) as Perc_Return
FROM  Transactions as T
join prod_cat_info  as P on T.prod_cat_code = P.prod_cat_code and T.prod_subcat_code = P.prod_sub_cat_code
where total_amt<0
GROUP  BY prod_subcat
 ) as  Y
on Z.prod_subcat = Y.prod_subcat)
order by Z.perc_sales desc



--11.	For all customers aged between 25 to 35 years find what is the net total revenue
--generated by these consumers in last 30 days of transactions from max transaction date available in the data?

select customer_id ,Dob ,tran_date ,  SUM(total_amt) as Revenue , floor(DATEDIFF(DAY , DOB , GETDATE())/365) as Current_age from Customer as C
join Transactions as T
on C.customer_Id = T.cust_id
where tran_date between dateadd(day,-30,(select max(tran_date) from transactions)) and (select MAX(tran_date) from Transactions)
group by customer_Id ,DOB , tran_date
having  (floor(DATEDIFF(DAY , DOB , GETDATE())/365) between 25 and 30 )




--12.	Which product category has seen the max value of returns in the last 3 months of transactions?
-- Ans Books 143 returns


select top 1 prod_cat ,  abs(sum(cast(Qty as int))) as No_of_units_returned from Transactions as T 
join prod_cat_info as P
on T.prod_cat_code = P.prod_cat_code and P.prod_sub_cat_code = T.prod_subcat_code
where Qty<0 and tran_date between DATEADD(Month,-3,(select max(tran_date) from Transactions)) and (select MAX(tran_date) from Transactions)
group by prod_cat
order  by No_of_units_returned desc





  --13.	Which store-type sells the maximum products; by value of sales amount and by quantity sold?
-- Ans e-Shop


 select top 1 store_type ,  sum(total_amt) _sum , sum(cast(Qty as int)) as _QTY from transactions
 group by Store_type 
 order by _sum desc , _QTY desc


--14.	What are the categories for which average revenue is above the overall average.

select prod_cat ,round(Avg(total_amt),2) as Avg_Revenue , (select round(AVG(total_amt),2) from Transactions) as Overall_Avg_revenue
from transactions as T
join prod_cat_info as P
on T.prod_cat_code = P.prod_cat_code and T.prod_subcat_code = P.prod_sub_cat_code
group by prod_cat
having Avg(total_amt) >(select AVG(total_amt) from Transactions)


   --15.	Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold

select prod_cat , prod_subcat , round(AVG(total_amt),2) as Avg_revenue , round(SUM(total_amt),2) as Total_revenue from Transactions as T1
join prod_cat_info as P1
on T1.prod_cat_code = P1.prod_cat_code and T1.prod_subcat_code = P1.prod_sub_cat_code
where prod_cat in(
select top 5 prod_cat from Transactions as T
join prod_cat_info as P
on T.prod_cat_code = P.prod_cat_code  and T.prod_subcat_code = P.prod_sub_cat_code 
group by prod_cat
order by SUM(cast(qty as int)) desc)
group by prod_cat , prod_subcat
order by prod_cat;



























