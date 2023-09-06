
--Cleaning and transforming Data Science Job Posting on Glassdoor Dataset

SELECT *
FROM Glassdoor..JobPostings$ 


-- Clean the 'SALARY ESTIMATE' column 

ALTER TABLE Glassdoor..JobPostings$ 
ADD Min_Salary FLOAT,
	Max_Salary FLOAT,
	Avg_Salary FLOAT;

-- Seperate 'SALARY ESTIMATE' into sepearate 'Min_Salary' and 'Max_Salary' columns

UPDATE Glassdoor..JobPostings$
SET Min_Salary = 
    CASE
        WHEN [Salary Estimate] LIKE '%$%k%' THEN
            CAST(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(
                                SUBSTRING(
                                    [Salary Estimate], 
                                    2, 
                                    CHARINDEX('-', [Salary Estimate]) - 2
                                ), '$', ''
                            ), 'k', ''
                        ), 
                        SUBSTRING(
                            [Salary Estimate], 
                            CHARINDEX('(', [Salary Estimate]),
                            CHARINDEX(')', [Salary Estimate]) - CHARINDEX('(', [Salary Estimate]) + 1
                        ), ''
                    ), '-', ''
                ) AS NUMERIC(10, 2)
            )
    END,
    Max_Salary = 
    CASE
        WHEN [Salary Estimate] LIKE '%$%k%' THEN
            CAST(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(
                                SUBSTRING(
                                    [Salary Estimate], 
                                    CHARINDEX('-', [Salary Estimate]) + 1, 
                                    LEN([Salary Estimate]) - CHARINDEX('-', [Salary Estimate])
                                ), '$', ''
                            ), 'k', ''
                        ), 
                        SUBSTRING(
                            [Salary Estimate], 
                            CHARINDEX('(', [Salary Estimate]),
                            CHARINDEX(')', [Salary Estimate]) - CHARINDEX('(', [Salary Estimate]) + 1
                        ), ''
                    ), '-', ''
                ) AS NUMERIC(10, 2)
            )
    END;

-- Create 'Avg_Salary' Column

UPDATE Glassdoor..JobPostings$
SET Avg_Salary = (Min_Salary + Max_Salary) / 2.0;


-- Convert 'RATING' Column

ALTER TABLE Glassdoor..JobPostings$ 
ADD RatingNum FLOAT

UPDATE Glassdoor..JobPostings$
SET RatingNum = 
    CASE
        WHEN ISNUMERIC([Rating]) = 1 AND CAST([Rating] AS NUMERIC(10, 2)) >= 0 THEN
            CAST([Rating] AS NUMERIC(10, 2))
        ELSE
            0.0
    END;

	
-- Clean 'COMPANY NAME' Column

ALTER TABLE Glassdoor..JobPostings$
ALTER COLUMN [Company Name]  VARCHAR(MAX) NULL;

ALTER TABLE Glassdoor..JobPostings$ 
ADD CompanyName NVARCHAR(MAX)

UPDATE Glassdoor..JobPostings$
SET CompanyName = 
    CASE 
        WHEN PATINDEX('%[0-9].[0-9]%', [Company Name]) > 0 THEN
            SUBSTRING([Company Name], 1, PATINDEX('%[0-9].[0-9]%', [Company Name]) - 1)
        ELSE
            [Company Name]
    END;

-- Get state from 'Location' Column

ALTER TABLE Glassdoor..JobPostings$ 
ADD Job_State NVARCHAR(MAX)

UPDATE Glassdoor..JobPostings$
SET Job_State = RIGHT(Location, CHARINDEX(',', REVERSE(Location)) - 1)
WHERE CHARINDEX(',', Location) > 0;

-- Check if state as headquarter or not

ALTER TABLE Glassdoor..JobPostings$ 
ADD Same_State NVARCHAR(MAX)


UPDATE Glassdoor..JobPostings$
SET Same_State = 
    CASE 
        WHEN Location = Headquarters THEN 1
        ELSE 0
    END;

-- Find the Age of company

UPDATE Glassdoor..JobPostings$
SET Founded = TRY_CONVERT(date, founded, 120);

ALTER TABLE Glassdoor..JobPostings$ 
ADD Company_Age FLOAT

UPDATE Glassdoor..JobPostings$
SET Company_Age = DATEDIFF(YEAR, Founded, GETDATE());


--- Create skills in boolean columns form

ALTER TABLE Glassdoor..JobPostings$ 
ADD Python FLOAT,
	excel FLOAT,
	hadoop FLOAT,
	spark FLOAT,
	aws FLOAT,
	tableau FLOAT,
	big_data FLOAT;

UPDATE Glassdoor..JobPostings$ 
SET Python = CASE 
    WHEN CHARINDEX('python', [Job Description], 1) > 0 THEN 1
    ELSE 0
END,
	excel = CASE 
    WHEN CHARINDEX('excel', [Job Description], 1) > 0 THEN 1
    ELSE 0
END,
	hadoop = CASE 
    WHEN CHARINDEX('hadoop', [Job Description], 1) > 0 THEN 1
    ELSE 0
END,
	spark = CASE 
    WHEN CHARINDEX('spark', [Job Description], 1) > 0 THEN 1
    ELSE 0
END,
	aws = CASE 
    WHEN CHARINDEX('aws', [Job Description], 1) > 0 THEN 1
    ELSE 0
END,
	tableau = CASE 
    WHEN CHARINDEX('tableau', [Job Description], 1) > 0 THEN 1
    ELSE 0
END,
	big_data = CASE 
    WHEN CHARINDEX('big data', [Job Description], 1) > 0 THEN 1
    ELSE 0
END;

--- Form job type 

ALTER TABLE Glassdoor..JobPostings$ 
ADD job_simp NVARCHAR(MAX)

UPDATE Glassdoor..JobPostings$ 
SET job_simp = CASE 
    WHEN [Job Title] LIKE '%data scientist%' THEN
	'data scientist'
	WHEN [Job Title] LIKE '%analyst%' THEN
	'analyst'
	WHEN [Job Title] LIKE '%data engineer%' THEN
	'data engineer'
	WHEN [Job Title] LIKE '%director%' THEN
	'director'
	WHEN [Job Title] LIKE '%manager%' THEN
	'manager'
	WHEN [Job Title] LIKE '%Machine Learning%' THEN
	'mle'
    ELSE 'n/a'
END;

-- Form job type is senior or not 

ALTER TABLE Glassdoor..JobPostings$ 
ADD seniority NVARCHAR(MAX)

UPDATE Glassdoor..JobPostings$
SET seniority = CASE 
    WHEN [Job Title] LIKE '%senior%' OR [Job Title] LIKE '%sr%' THEN
        'senior'
    WHEN [Job Title] LIKE '%jr%' THEN
        'junior'
    ELSE 'N/A'
END;

-- Drop unnecessary columns

ALTER TABLE Glassdoor..JobPostings$
DROP COLUMN [index],
	 COLUMN Founded,
	 COLUMN [Salary Estimate],
	 COLUMN Rating,
	 COLUMN [Company Name],
	 COLUMN Salary;


