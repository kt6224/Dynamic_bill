-- Dropping existing database if exists and creating a new one

DROP DATABASE IF EXISTS project;

-- Created Database

CREATE DATABASE project;
USE project;

-- Renaming table and changing column names because column name are same as keyword
ALTER TABLE assignmnet RENAME TO bill_details;

-- changed column name
ALTER TABLE bill_details CHANGE COLUMN `Plan ID` Plan_id INT;

-- changed column name
ALTER TABLE bill_details CHANGE COLUMN `Usage` Usage_ INT;

select * from bill_details;

-- Separating the UsageRateslabs column in to different parts by making a view

-- it will give us Part1,Part2,Part3,Part4,Part5 separate columns

CREATE VIEW View1 AS
SELECT Plan_id, PlanName, Usage_, BillValue,
       SUBSTRING_INDEX(UsageRateSlabs, '|', 1) AS Part1,
       CASE WHEN LENGTH(UsageRateSlabs) - LENGTH(REPLACE(UsageRateSlabs, '|', '')) >= 1 THEN 
                SUBSTRING_INDEX(SUBSTRING_INDEX(UsageRateSlabs, '|', 2), '|', -1) ELSE NULL END AS Part2,
       CASE WHEN LENGTH(UsageRateSlabs) - LENGTH(REPLACE(UsageRateSlabs, '|', '')) >= 2 THEN 
                SUBSTRING_INDEX(SUBSTRING_INDEX(UsageRateSlabs, '|', 3), '|', -1) ELSE NULL END AS Part3,
       CASE WHEN LENGTH(UsageRateSlabs) - LENGTH(REPLACE(UsageRateSlabs, '|', '')) >= 3 THEN 
                SUBSTRING_INDEX(SUBSTRING_INDEX(UsageRateSlabs, '|', 4), '|', -1) ELSE NULL END AS Part4,
       CASE WHEN LENGTH(UsageRateSlabs) - LENGTH(REPLACE(UsageRateSlabs, '|', '')) >= 4 THEN 
                SUBSTRING_INDEX(SUBSTRING_INDEX(UsageRateSlabs, '|', 5), '|', -1) ELSE NULL END AS Part5
FROM bill_details;

-- Again Created a view to separate Part values and their rates from the different Parts columns

CREATE VIEW View2 AS
SELECT Plan_id, PlanName, Usage_, BillValue,
    SUBSTRING_INDEX(Part1, ',', 1) AS Part1,
    SUBSTRING_INDEX(Part1, ',', -1) AS p1,
    SUBSTRING_INDEX(Part2, ',', 1) AS Part2,
    SUBSTRING_INDEX(Part2, ',', -1) AS p2,
    SUBSTRING_INDEX(Part3, ',', 1) AS Part3,
    SUBSTRING_INDEX(Part3, ',', -1) AS p3,
    SUBSTRING_INDEX(Part4, ',', 1) AS Part4,
    SUBSTRING_INDEX(Part4, ',', -1) AS p4,
    SUBSTRING_INDEX(Part5, ',', 1) AS Part5,
    SUBSTRING_INDEX(Part5, ',', -1) AS p5
FROM View1;

-- Updating data where PlanName matches specific values (just for checking the logic we can use)
UPDATE bill_details
SET Usage_ = 33000
WHERE PlanName IN ('PlanA', 'PlanB', 'PlanC','PlanD','PlanE');

-- Used case when for different PLANS 
-- Made a condition from the given file in the project
-- so that it will calculate bill_value accordingly
-- New Column named Dynamic_bill_value created

SELECT Plan_id, PlanName, Usage_, BillValue,
    CASE 
        WHEN PlanName='PlanA' THEN
            CASE 
                WHEN Usage_ <= Part1 THEN  Usage_ * p1
                WHEN Usage_ > Part1 AND Usage_<= (Part1 + Part2) THEN (Part1 * p1) +(Usage_ - Part1)*p2 
                WHEN Usage_ > (Part1 + Part2) AND Usage_<= (Part1 + Part2 + Part3) THEN (Part1 * p1) +(Part2 * p2)+(Usage_ - (Part1+Part2))*p3 
                WHEN Usage_ > (Part1 + Part2 + Part3) AND Usage_<= 99999 THEN (Part1 * p1) +(Part2 * p2)+(Part3 * p3)+(Usage_ - (Part1+Part2+Part3))*p4
            END
        WHEN PlanName='PlanB' THEN
            CASE 
                WHEN Usage_ <= Part1 THEN  Usage_ * p1
                WHEN Usage_ > Part1 AND Usage_<= (Part1 + Part2) THEN (Part1 * p1) +(Usage_ - Part1)*p2 
                WHEN Usage_ > (Part1 + Part2) AND Usage_<= (Part1 + Part2 + Part3) THEN (Part1 * p1) +(Part2 * p2)+(Usage_ - (Part1+Part2))*p3 
                WHEN Usage_ > (Part1 + Part2 + Part3) AND Usage_<= (Part1 + Part2 + Part3 + Part4)  THEN (Part1 * p1) +(Part2 * p2)+(Part3 * p3)+(Usage_ - (Part1+Part2+Part3))*p4
                WHEN Usage_ > (Part1 + Part2 + Part3 + Part4) AND Usage_<=99999  THEN (Part1 * p1) +(Part2 * p2)+(Part3 * p3)+(Part4 * p4)+(Usage_ - (Part1+Part2+Part3+Part4))*p5
            END
        WHEN PlanName='PlanC' THEN
            CASE
                WHEN Usage_ <= Part1 THEN  Usage_ * p1
                WHEN Usage_ > Part1 AND Usage_<= (Part1 + Part2) THEN (Part1 * p1) +(Usage_ - Part1)*p2 
                WHEN Usage_ > (Part1 + Part2) AND Usage_< 99999 THEN (Part1 * p1) +(Part2 * p2)+(Usage_ - (Part1+Part2))*p3 
            END
        WHEN PlanName='PlanD' THEN Usage_ * p1
        WHEN PlanName='PlanE' THEN
            CASE
                WHEN Usage_ <= Part1 THEN  Usage_ * p1
                WHEN Usage_ > Part1 AND Usage_<= 99999 THEN (Part1 * p1) +(Usage_ - Part1)*p2 
            END
    END AS Dynamic_bill_value
FROM View2;

-- Thank You

