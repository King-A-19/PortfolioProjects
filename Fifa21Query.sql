--Cleaning and transforming FIFA21 dataset

SELECT *
FROM Fifa21..Players$

-- Convert the height and weight columns

UPDATE Fifa21..Players$
SET 
    Height = REPLACE (Height, 'cm', ''),
    Weight = REPLACE (Weight, 'kg', '');

SELECT Height, Weight,
CASE WHEN ISNUMERIC (Height) = 1 AND ISNUMERIC (Weight) = 1 THEN
CONCAT (CAST ((CAST (Height AS DECIMAL (18,4))/ (CAST (Weight AS DECIMAL (18,4))*12))*100 AS DECIMAL (18,2)),'%')
ELSE NULL
END AS ExpectedResult
FROM Fifa21..Players$


-- Clean Currency Columns

ALTER TABLE Fifa21..Players$
ADD ValueNum FLOAT,
	WageNum FLOAT,
	ReleaseClauseNum FLOAT;

BEGIN TRY
	UPDATE Fifa21..Players$
	SET ValueNum = CASE
		WHEN Value LIKE '%M%' THEN
CAST(REPLACE(REPLACE( Value, '€', ''), 'M', '') AS FLOAT) * 1000000
		WHEN Value LIKE '%K%' THEN
CAST(REPLACE(REPLACE( Value, '€', ''), 'K', '') AS FLOAT) * 1000
		ELSE CAST(REPLACE ( Value, '€', '') AS FLOAT)
		END,
		WageNum = CASE
		WHEN Wage LIKE '%M%' THEN
CAST(REPLACE(REPLACE( Wage, '€', ''), 'M', '') AS FLOAT) * 1000000
		WHEN Wage LIKE '%K%' THEN
CAST(REPLACE(REPLACE( Wage, '€', ''), 'K', '') AS FLOAT) * 1000
		ELSE CAST(REPLACE ( Wage, '€', '') AS FLOAT)
		END,
		ReleaseClauseNum = CASE
		WHEN [Release Clause] LIKE '%M%' THEN
CAST(REPLACE(REPLACE( [Release Clause], '€', ''), 'M', '') AS FLOAT) * 1000000
		WHEN [Release Clause] LIKE '%K%' THEN
CAST(REPLACE(REPLACE( [Release Clause], '€', ''), 'K', '') AS FLOAT) * 1000
		ELSE CAST(REPLACE ( [Release Clause], '€', '') AS FLOAT)
		END;
END TRY
BEGIN CATCH
	PRINT 'Error occured while converting ';
	PRINT ERROR_MESSAGE();
END CATCH;

-- Drop orignal columns

ALTER TABLE Fifa21..Players$
DROP COLUMN Value,
	 COLUMN Wage,
	 COLUMN [Release Clause];

-- Clean Columns That Have the 'star' Symbol

-- Modify the [W/F] column
ALTER TABLE Fifa21..Players$
ALTER COLUMN [W/F] VARCHAR(MAX) NULL;

-- Modify the SM column
ALTER TABLE Fifa21..Players$
ALTER COLUMN SM VARCHAR(MAX) NULL;

-- Modify the IR column
ALTER TABLE Fifa21..Players$
ALTER COLUMN IR VARCHAR(MAX) NULL;
	
        
UPDATE Fifa21..Players$
SET [W/F] = CASE
    WHEN ISNUMERIC(REPLACE([W/F], '?', '')) = 1 THEN 
        CAST(REPLACE([W/F], '?', '') AS numeric)
    ELSE NULL
END,
SM = CASE
    WHEN ISNUMERIC(REPLACE(SM, '?', '')) = 1 THEN
        CAST(REPLACE(SM, '?', '') AS numeric)
    ELSE NULL 
END,
IR = CASE
    WHEN ISNUMERIC(REPLACE(IR, '?', '')) = 1 THEN
        CAST(REPLACE(IR, '?', '') AS numeric)
    ELSE NULL
END;


-- Seperate the 'Contract Column'

ALTER TABLE Fifa21..Players$
ADD ContractStart DATE,
    ContractEnd DATE;

-- Update the new columns with values extracted from the 'Contract' column

UPDATE Fifa21..Players$
SET	ContractStart = CASE 
        WHEN CHARINDEX('~', Contract) > 0 THEN 
			CAST(SUBSTRING(Contract, 1, CHARINDEX('~', Contract) - 1) AS DATE)
        ELSE NULL 
    END,
    ContractEnd = CASE 
        WHEN CHARINDEX('~', Contract) > 0 THEN 
			CAST(SUBSTRING(Contract, CHARINDEX('~', Contract) + 1, 
			LEN(Contract)) AS DATE)
        ELSE NULL 
    END;


-- Convert 'Joined' from character string to Date

ALTER TABLE Fifa21..Players$
ADD NewJoined DATE;

UPDATE Fifa21..Players$
SET NewJoined = CONVERT(DATE,Joined, 107);

-- Check which players have been playing at a club for more than 10 years

SELECT Name, Club, Joined, Contract  
FROM Fifa21..Players$
WHERE DATEDIFF(year, NewJoined, ContractEnd) > 10;

-- Which players are highly valuable but still underpaid

SELECT Name, ValueNum, WageNum
FROM Fifa21..Players$
WHERE ValueNum > 50000000 AND WageNum < 200000;




