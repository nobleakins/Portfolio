-- Select * all tables
Select * FROM [mev_toy].[dbo].[inventory-230126-100430]
Select * FROM [mev_toy].[dbo].[products-230126-100423]
Select * FROM [mev_toy].[dbo].[sales-230126-100644]
Select * FROM [mev_toy].[dbo].[stores-230126-100412]

-- Which product categories drive the biggest profits? Is this the same across store locations?

SELECT
        s.Store_ID,
        p.Product_Category,
        SUM(s.Units * (p.Product_Price - p.Product_Cost)) AS TotalProfit
    FROM [mev_toy].[dbo].[sales-230126-100644] s
    JOIN [mev_toy].[dbo].[products-230126-100423] p ON s.Product_ID = p.Product_ID
    GROUP BY s.Store_ID, p.Product_Category

	
	-- How much money is tied up in inventory at the toy stores? How long will it last?
SELECT
    i.Store_ID,
    SUM(i.Stock_On_Hand * p.Product_Price) AS TotalInventoryValue,
    SUM(i.Stock_On_Hand * p.Product_Price) / AVG(daily_sales.DailySales) AS DaysToSellOut
FROM [mev_toy].[dbo].[inventory-230126-100430] i
JOIN [mev_toy].[dbo].[products-230126-100423] p ON i.Product_ID = p.Product_ID
JOIN (
    SELECT Store_ID, AVG(Units) AS DailySales
    FROM [mev_toy].[dbo].[sales-230126-100644]
    GROUP BY Store_ID
) daily_sales ON i.Store_ID = daily_sales.Store_ID
GROUP BY i.Store_ID;

-- Are sales being lost with out-of-stock products at certain locations?
SELECT
    s.Store_ID,
    p.Product_Name,
    COUNT(CASE WHEN i.Stock_On_Hand = 0 THEN 1 ELSE NULL END) AS OutOfStockCount,
    SUM(s.Units) AS LostSales
FROM [mev_toy].[dbo].[sales-230126-100644] s
JOIN [mev_toy].[dbo].[inventory-230126-100430] i ON s.Store_ID = i.Store_ID AND s.Product_ID = i.Product_ID
JOIN [mev_toy].[dbo].[products-230126-100423] p ON s.Product_ID = p.Product_ID
GROUP BY s.Store_ID, p.Product_Name

-- Finding the top-selling products in each store
SELECT
    s.Store_ID,
    p.Product_Name,
    SUM(s.Units) AS TotalUnitsSold
FROM [mev_toy].[dbo].[sales-230126-100644] s
JOIN [mev_toy].[dbo].[products-230126-100423] p ON s.Product_ID = p.Product_ID
GROUP BY s.Store_ID, p.Product_Name
ORDER BY s.Store_ID, TotalUnitsSold DESC;

-- Calculating the average transaction value for each store
SELECT
    s.Store_ID,
    AVG(s.Units * p.Product_Price) AS AverageTransactionValue
FROM [mev_toy].[dbo].[sales-230126-100644] s
JOIN [mev_toy].[dbo].[products-230126-100423] p ON s.Product_ID = p.Product_ID
GROUP BY s.Store_ID
ORDER BY s.Store_ID;

-- Identifying stores with consistently low inventory levels
SELECT
    i.Store_ID,
    AVG(i.Stock_On_Hand) AS AverageInventoryLevel
FROM [mev_toy].[dbo].[inventory-230126-100430] i
GROUP BY i.Store_ID
HAVING AVG(i.Stock_On_Hand) < 20;




