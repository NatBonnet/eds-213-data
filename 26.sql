-- Filtering
-- looks like R or Python
SELECT * FROM Site WHERE Area < 200;
SELECT  * FROM Site WHERE Area < 200 AND Latitude > 60;

-- older style operators
SELECT * FROM Site WHERE Code != 'iglo';
SELECT * FROM Site WHERE Code <> 'iglo'; 
-- end older style

-- expression: the usual operators plus functions like regex

## EXPRESSIONS
SELECT Site_name, Area*2.47 FROM Site;

-- naming columns
SELECT Site_name, Area*2.47 AS Area_acres FROM Site;

-- string concatenation
-- old style operator is ||
SELECT Site_name || ', ' || Location AS Full_name FROM Site;

-- you can also just run expressions without selecting from any data
SELECT 2+2;

## AGGREGATION & GROUPING
-- how many rows are in a table
SELECT COUNT(*) FROM Bird_nests;
-- the * means count rows 

-- we can also ask how many non-null values there are
SELECT COUNT(*) FROM Species;
SELECT COUNT(Scientific_name) FROM Species;
-- putting a column name counts non null values

-- counting number of distinct things
SELECT COUNT(*) FROM Site;
SELECT COUNT(DISTINCT Location) FROM Site; -- number of distinct locations
SELECT COUNT(Location) FROM Site; --number of non-null locations

-- Find what they are
SELECT DISTINCT Location FROM Site;

-- aggregation functions
SELECT AVG(Area) FROM Site;
SELECT MIN(Area) FROM Site;
SELECT MAX(Area) FROM Site;


-- enter grouping 
SELECT Location, AVG(Area) FROM Site GROUP BY Location;
-- can do for counting
SELECT Location, COUNT(*) FROM Site GROUP BY Location;

-- WHERE clauses
SELECT Location, COUNT(*) 
FROM Site 
WHERE Location 
LIKE '%Canada' -- old style pattern matching not full regex just a wildcard
GROUP BY Location;

-- he order of the clauses represents order of processing
-- what if you want to do filtering on groups after you've done grouping?
SELECT Location, MAX(Area) AS Max_area
FROM Site
WHERE Location LIKE '%Canada'
GROUP BY Location
HAVING Max_area > 200 --applies after grouping
ORDER BY Max_area DESC; 

## RELATIONAL ALGEBRA
-- everything is a table
-- every statement returns a table
-- you can save tables, nest queries, if everything is a table you're always returning tables
SELECT COUNT(*) FROM ( 
    SELECT COUNT (*) FROM Site
); -- returns a table counting how many numbers are returned from the nested query

-- you can nest queries 
SELECT DISTINCT Species FROM Bird_nests; -- only returns those with observations

-- returning rows with no observations
SELECT Code FROM Species 
WHERE Code NOT IN (SELECT DISTINCT Species FROM Bird_nests);

## NULL PROCESSING
-- NULL is infectious 
-- in a table NULL means the absence of a value
SELECT COUNT(*) FROM Bird_nests WHERE ageMethod == 'float'; -- if ageMethod is NULL it returns an unknown rather than T or F

-- select rows where there are nulls
SELECT COUNT(*) FROM Bird_nests WHERE ageMethod = NULL; -- NO THIS DOESN'T WORK

SELECT COUNT(*) FROM Bird_nests WHERE ageMethod IS NULL; 
--and
SELECT COUNT(*) FROM Bird_nests WHERE ageMethod IS NOT NULL; 

## JOINS 
-- 90% of the time you join tables based on a FK relationship
SELECT * FROM Camp_assignment;

-- get all columns of both tables
SELECT * FROM Camp_assignment JOIN Personnel
ON Observer = Abbreviation
LIMIT 10; -- return head

-- join is very general, can apply to any table with any expression joining them
-- joins always start from a Cartesian product of the table
-- CROSS JOIN = no condition match every row from one table with every row from the other
SELECT * FROM Site CROSS JOIN Species; --combining every possible row

-- *any* condition can be expression but usually you want to join on a FK 
-- joining on a FK- the result is the same as the table with the foreign key but with additional columns
SELECT * FROM Bird_nests BN JOIN Species S -- same as AS BN
ON BN.Species = S.Code
LIMIT 5;
--should have the same number of rows
SELECT COUNT(*) FROM Bird_nests BN JOIN Species S
ON BN.Species = S.Code
LIMIT 5;
