							 --Exploration Data

--Show All Data After loading
select *
from Sales

--Count total row
select count(*) as Count_Row
from Sales

							 --Check The Quality of Data

--check if exist a missing or null value
select *
from Sales
where Final_Quantity is null
or Final_Revenue is null
or Overall_Revenue is null 
 
-- Check if Transaction not valid
select *
From Sales
where Final_Quantity <=0

							--Analysis the Refundes 

--Count transaction refundes
select count(*) AS Refund_count
from Sales
where Refunds <0			

-- Show this refundes
select *
from Sales
where Refunds <0

-- total refundes amount
select sum(ABS(Refunds)) as Total_Refund_Amount
from Sales

				     -- Sales and Refunds states

--completed Sales (no refends)
select* 
from Sales
where Final_Quantity >0 and Refunds=0
 
--partial refunds (some sold and some refunds) 
select* 
from Sales
where Final_Quantity >0 and Refunds <0

--full refunds 
select* 
from Sales
where Final_Quantity <=0 and Refunds<0
				
-- incompleted process(quantity refund without customer'money)
select* 
from Sales
where Final_Quantity <=0 and Refunds =0
			
							--The Important KPIS 

--Total Revenue(before any refunds or discound, tax) & Net Revenue(after tax,discound and refunds)
select sum(Total_Revenue) As Total_Revenue,
	   sum(Overall_Revenue) As Net_Revenue
from Sales

--Total Refunded Amount, Refund Rate
Select Sum(ABS(Refunds)) as Total_Refunded,
	   ROUND(Sum(ABS(Refunds))*100/sum(Total_Revenue),0) As Refund_Rate
from Sales
where Refunds<0

--total item sold ,refund and it's Return Item Rate
select 
	sum(case when Final_Quantity>0 then Final_Quantity else 0 end) Total_Ttem_Sold,
	
	sum(case when Final_Quantity<=0 then Final_Quantity else 0 end) as Total_Item_Refund,
	
	ROUND(ABS(sum(case when Final_Quantity<=0 then Final_Quantity else 0 end ))*100/
		sum(case when Final_Quantity>0 then Final_Quantity else 0 end),0) as Return_Item_Rate 
from sales

--Discount Rate
select ROUND(AVG(Price_Reductions),2) as Discount_Rate
from Sales
where Price_Reductions is not null

--AOV[Average order value]
select ROUND(avg(Overall_Revenue),0) as Average_order_value
from Sales

--Refund category with hight refund value
select top 5 Category,ROUND(Sum(ABS(Refunds)),0) as Total_Refound
from sales
where Refunds <0
group by Category
order by Total_Refound Desc

--Refund category with hight refund quanity
select top 5 Category,
	ABS(sum(case when Final_Quantity<0 then Final_Quantity else 0 end)) as Retuen_Quantity
from Sales
--where Final_Quantity <0
group by Category
order by Retuen_Quantity Desc

--best sold category with hight quanity sold
select top 5 Category,sum(Final_Quantity) as Total_quantity_sold
from Sales
where Final_Quantity>0
group by Category
order by Total_quantity_sold Desc

--best sold category  with hight value sold
select top 5 Category,Round(sum(Overall_Revenue),2) as Total_Revenue
from Sales
where Final_Quantity>0
group by Category
order by Total_Revenue desc

								-- Affect Discount on Sales & Return
								
-- average discount for 10 top item sold and also returned
select Item_Name,
		Round(ABS(avg(Price_Reductions)),2) as Avg_Discount,
	ROUND(sum(Overall_Revenue),2) as Total_Revenue,
	Abs(sum(case when Final_Quantity<0 then Final_Quantity else 0 end)) as Total_returned_QTY
from Sales
where Item_Name in (
					select top 10 Item_Name 
					from Sales
					group by Item_Name
					order by sum( Final_Quantity) desc
					)
Group by Item_Name
order by Avg_Discount desc

-- check if there relation between discount & return rate for this items
select top 10 Item_Name,
		Round(ABS(avg(Price_Reductions)),2) as Avg_Discount,
		Round(
			  ABS(sum(case when Final_Quantity<0 then Final_Quantity else 0 end))*100 /
			  nullif( 
					sum(case when Final_Quantity>0 then Final_Quantity else 0 end),0),2
			) as Return_rate_percent
from Sales
Group by Item_Name
having sum(Final_Quantity)>0
order by Return_rate_percent desc

--the item have a large discount and still returned
select top 10 Item_Name,
		Round(ABS(avg(Price_Reductions)),2) as Avg_Discount,
		ABS(sum(Price_Reductions)) as Total_Discount,
		ABS(Sum(Refunds))as Total_Refund_Value 
From Sales
where Price_Reductions < 0 and Refunds <0
Group by Item_Name
order by Total_Discount


