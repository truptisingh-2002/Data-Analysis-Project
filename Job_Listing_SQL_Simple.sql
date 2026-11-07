CREATE DATABASE DataAnalystJobsDB;
GO
USE DataAnalystJobsDB;
GO

CREATE TABLE JobListings (
    job_title NVARCHAR(255),
    company NVARCHAR(255),
    experience NVARCHAR(100),
    min_exp INT NULL,
    max_exp INT NULL,
    salary NVARCHAR(100) NULL,
    base_salary DECIMAL(18,2) NULL,
    max_salary DECIMAL(18,2) NULL,
    location NVARCHAR(255) NULL,
    days_ago INT NULL,
    posted_in NVARCHAR(150) NULL,
    rating DECIMAL(4,2) NULL,
    reviews_count INT NULL,
    details NVARCHAR(MAX) NULL,
    salary_source NVARCHAR(255) NULL
);
GO

-- Change the file path before running this statement.
BULK INSERT JobListings
FROM 'C:\YourFolder\cleaned_data_analyst_jobs_india.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', FIELDQUOTE = '"');
GO

-- Task 1: Top 5 companies by average rating
SELECT TOP 5 company, AVG(rating) AS average_rating
FROM JobListings
WHERE company IS NOT NULL AND rating IS NOT NULL
GROUP BY company
ORDER BY average_rating DESC;
GO

-- Task 2: Average salaries by location above the threshold
DECLARE @SalaryThreshold DECIMAL(18,2) = 100000;
WITH LocationSalary AS (
    SELECT location, AVG(base_salary) AS avg_base_salary,
           AVG(max_salary) AS avg_max_salary
    FROM JobListings
    WHERE location IS NOT NULL
    GROUP BY location
)
SELECT location, avg_base_salary, avg_max_salary
FROM LocationSalary
WHERE avg_base_salary > @SalaryThreshold
   OR avg_max_salary > @SalaryThreshold
ORDER BY avg_max_salary DESC;
GO

-- Task 3: Extract experience values such as '2-6 Yrs'
CREATE OR ALTER PROCEDURE UpdateExperience
AS
BEGIN
    UPDATE JobListings
    SET min_exp = TRY_CONVERT(INT, LEFT(experience, CHARINDEX('-', experience + '-') - 1)),
        max_exp = TRY_CONVERT(INT, SUBSTRING(experience, CHARINDEX('-', experience + '-') + 1, 2))
    WHERE experience IS NOT NULL;
END;
GO
EXEC UpdateExperience;
GO

-- The CSV has days_ago and posted_in, but no posting date.
-- Add a real posted_date before using the trigger.
ALTER TABLE JobListings ADD posted_date DATE NULL;
GO

CREATE OR ALTER TRIGGER UpdateDaysAgo
ON JobListings
AFTER INSERT
AS
BEGIN
    UPDATE j
    SET days_ago = DATEDIFF(DAY, i.posted_date, CAST(GETDATE() AS DATE))
    FROM JobListings AS j
    JOIN inserted AS i ON j.job_title = i.job_title
                      AND (j.company = i.company OR (j.company IS NULL AND i.company IS NULL))
    WHERE i.posted_date IS NOT NULL;
END;
GO

-- Task 4: Jobs with both salary values available
CREATE OR ALTER VIEW CompleteSalaryJobListings AS
SELECT job_title, company, location, base_salary, max_salary
FROM JobListings
WHERE base_salary IS NOT NULL AND max_salary IS NOT NULL;
GO

-- Basic data checks
SELECT COUNT(*) AS total_rows FROM JobListings;
SELECT COUNT(*) AS duplicate_rows
FROM (SELECT job_title, company, experience, COUNT(*) AS n
      FROM JobListings GROUP BY job_title, company, experience HAVING COUNT(*) > 1) AS d;
SELECT COUNT(*) AS missing_salary_rows
FROM JobListings WHERE base_salary IS NULL OR max_salary IS NULL;
SELECT COUNT(*) AS invalid_salary_rows
FROM JobListings WHERE base_salary > max_salary;
GO
