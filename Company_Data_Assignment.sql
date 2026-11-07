Q1. Display the Business_Name, Business_Type, City, and Profit for businesses whose Profit is greater than the overall average Profit. Sort the results by Profit in descending order.

SELECT
    Business_Name,
    Business_Type,
    City,
    Profit
FROM Business_Data
WHERE Profit > (SELECT AVG(Profit) FROM Business_Data)
ORDER BY Profit DESC;


Q2. Create a view that contains Business_Name, Business_Type, City, Sales, Expenses, and Profit for all businesses. Retrieve the businesses from this view that have Sales greater than 2,000,000 and Profit greater than 500,000.

CREATE OR ALTER VIEW Business_Sales_Profit_View
AS
SELECT
    Business_Name,
    Business_Type,
    City,
    Sales,
    Expenses,
    Profit
FROM Business_Data;
GO

SELECT
    Business_Name,
    Business_Type,
    City,
    Sales,
    Expenses,
    Profit
FROM Business_Sales_Profit_View
WHERE Sales > 2000000
  AND Profit > 500000;


Q3. Display each Business_Type along with its total Sales, total Expenses, total Profit, and number of Businesses. Display only business types where the total Profit is greater than 5,000,000.

SELECT
    Business_Type,
    SUM(Sales) AS Total_Sales,
    SUM(Expenses) AS Total_Expenses,
    SUM(Profit) AS Total_Profit,
    COUNT(*) AS Number_of_Businesses
FROM Business_Data
GROUP BY Business_Type
HAVING SUM(Profit) > 5000000
ORDER BY Total_Profit DESC;
