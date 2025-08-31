select * from dbo.blinkit_data


----------------------------Data cleaning------------------------

-- to update content like LF,low fat ,reg into regular content like Low Fat & Regular to make data clean
update blinkit_data
set Item_Fat_Content =
case
when Item_Fat_Content in ('LF','low fat') then 'Low Fat'
when Item_Fat_Content ='reg' then 'Regular'
else Item_Fat_Content
end

-- to check whether content is now regular or not
select distinct (item_fat_content) from blinkit_data


/* 
KPI requirements : 
1. total sales  2. Average sales  3. nu of items  4. average rating
*/

----------------  1.total sales  ---------------
select sum(total_sales) Total_sales from blinkit_data

--to get output in million & upto two decimal points
select concat(cast(sum(total_sales)/1000000 as decimal(10,2)),' Millons') Total_sales_Millions from blinkit_data


----------------  2.Average sales  ---------------
select avg(total_sales) Average_sales from blinkit_data

--to get output in million & upto two decimal points
select concat(cast(avg(total_sales) as decimal(10,1)),' Millons') Average_sales_Millions from blinkit_data


----------------  3.nu of items---------------

select count(*) nu_of_items from blinkit_data

----------------  4.Average rating---------------

select cast(avg(Rating)as decimal(10,2)) Avg_Rating from blinkit_data



--1. Total Sales by Fat Content:
	--Objective: Analyze the impact of fat content on total sales.
	--Additional KPI Metrics: Assess how other KPIs (Average Sales, Number of Items, Average Rating) vary with fat content.

select Item_Fat_Content,concat(cast(sum(Total_Sales)/1000000 as decimal(10,2) ),' M') Total_sales_Millions,
          concat(cast(avg(total_sales) as decimal(10,1)),' M') Average_sales_Millions,
		  count(*) nu_of_items,
		  cast(avg(Rating)as decimal(10,2)) Avg_Rating
from blinkit_data
group by Item_Fat_Content
order by Total_sales_Millions desc



--2. Total Sales by Item Type:
	--Objective: Identify the performance of different item types in terms of total sales.
	--Additional KPI Metrics: Assess how other KPIs (Average Sales, Number of Items, Average Rating) vary with fat content.

select Item_Type,
	      cast(sum(Total_Sales) as decimal(10,2) ) Total_sales,
          concat(cast(avg(total_sales) as decimal(10,1)),' M') Average_sales_Millions,
		  count(*) nu_of_items,
		  cast(avg(Rating)as decimal(10,2)) Avg_Rating
from blinkit_data
group by Item_Type
order by Total_sales desc


--3. Fat Content by Outlet for Total Sales:
	--Objective: Compare total sales across different outlets segmented by fat content.
	--Additional KPI Metrics: Assess how other KPIs (Average Sales, Number of Items, Average Rating) vary with fat content.

SELECT Outlet_Location_Type, 
       ISNULL([Low Fat], 0) AS Low_Fat, 
       ISNULL([Regular], 0) AS Regular
FROM 
(
    SELECT Outlet_Location_Type, Item_Fat_Content, 
           CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
    FROM blinkit_data
    GROUP BY Outlet_Location_Type, Item_Fat_Content
) AS SourceTable
PIVOT 
(
    SUM(Total_Sales) 
    FOR Item_Fat_Content IN ([Low Fat], [Regular])
) AS PivotTable
ORDER BY Outlet_Location_Type;


--4. Total Sales by Outlet Establishment:
	--Objective: Evaluate how the age or type of outlet establishment influences total sales.

SELECT Outlet_Establishment_Year, 
          cast(sum(Total_Sales) as decimal(10,2) ) Total_sales,
          concat(cast(avg(total_sales) as decimal(10,1)),' M') Average_sales_Millions,
		  count(*) nu_of_items,
		  cast(avg(Rating)as decimal(10,2)) Avg_Rating
FROM blinkit_data
GROUP BY Outlet_Establishment_Year
ORDER BY Outlet_Establishment_Year

--5. Percentage of Sales by Outlet Size:
	--Objective: Analyze the correlation between outlet size and total sales.

SELECT 
    Outlet_Size, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage
FROM blinkit_data
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;



--6. Sales by Outlet Location:
	--Objective: Assess the geographic distribution of sales across different locations.

SELECT Outlet_Location_Type, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_data
GROUP BY Outlet_Location_Type
ORDER BY Total_Sales DESC



--7. All Metrics by Outlet Type:
	--Objective: Provide a comprehensive view of all key metrics (Total Sales, Average Sales, Number of 	Items, Average Rating) broken down by different outlet types.

SELECT Outlet_Type, 
        CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
		CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Avg_Sales,
		COUNT(*) AS No_Of_Items,
		CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating,
		CAST(AVG(Item_Visibility) AS DECIMAL(10,2)) AS Item_Visibility
FROM blinkit_data
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC

