--tri-value logic
--expressions can have a value (if booleon TRUE or FALSE) but can also be null

SELECT COUNT(*) FROM Bird_nests
WHERE floatAge < 7 OR floatAge >= 7;

SELECT COUNT(*) FROM Bird_nests 
WHERE floatAge IS NULL;

--relational algebra
--Everything is a table, every operation returns a table
--Even COUNT(*) returns a table

SELECT COUNT(*) FROM Bird_nests

--Nesting selects

SELECT Scientific_name
FROM Species
WHERE Code NOT IN (SELECT DISTINCT Species FROM Bird_nests );

SELECT Location, MAX(Area) AS Max_area
FROM Site
WHERE Location LIKE '%Canada' --applying to columnsGet-Item "$env:LOCALAPPDATA\DuckDB\duckdb.exe"
GROUP BY Location
HAVING Max_area > 200; --applies to groups

--Review of joins
SELECT * FROM A CROSS JOIN B; --multiplies the number of rows

SELECT * FROM A;

SELECT * FROM B;

--Adding join condition
SELECT * FROM A JOIN B ON acol1 < bcol1;

SELECT * FROM A INNER JOIN B ON acol1 < bcol1;

outer join: adding rows from one table that never got matched

SELECT * FROM A RIGHT JOIN B ON acol1 < bcol1;

SELECT * FROM A LEFT JOIN B ON acol1 < bcol1;

SELECT * FROM A FULL OUTER JOIN B ON acol1 < bcol1;

--Joining on a foreign key relationship is much more common

SELECT * FROM House;
SELECT * FROM Students;

--Typically:
SELECT * FROM Student S JOIN House H ON S.House_ID = H.House_ID;

--If you have the same name you can join using USING

SELECT * FROM STUDENT JOIN House USING (House_ID); --need to use parentheses for syntax for some reason

SELECT Nest_ID ANY_VALUE(Species), COUNT (*)
FROM Bird_eggs JOIN BIrd_nests USING (Nest_ID)
GROUP BY Nest_ID;

SELECT Nest_ID, Species, Egg_num, Width, Length FROM
Bird_eggs JOIN Bird_nests USING (Nest_ID)
ORDER BY Nest_ID, Egg_num
LIMIT 10;

-- Wednesday session
SELECT * FROM A;

SELECT * FROM B;

-- can still join tables without a relationship between a primary and foreign key with cross join (cartesian product of all the rows)
SELECT * FROM A CROSS JOIN B;
-- we expect the resulting number of rows to be 3x3 (all the possible combinations between the two)

-- select first 2 columns form product of cross join
SELECT acol1, acol2 -- desired column output
FROM (SELECT * FROM A CROSS JOIN B); --computes this first then selects

-- COUNT() ignores all null values 
SELECT acol1, ANY_VALUE(acol2), -- want these columns- duckdb doesn't know which row to select because there are 3 of each so just say any
COUNT(*) -- count number of rows in eacch acol1 group
FROM (SELECT * FROM A CROSS JOIN B) -- from join
GROUP BY acol1;

SELECT acol1, ANY_VALUE(acol2), 
COUNT(bcol3) --count rows ignoring NULL values in column b3
FROM (SELECT * FROM A CROSS JOIN B) 
GROUP BY acol1;

-- join using a condition
SELECT * FROM A JOIN B ON acol1 < bcol1; -- join when acol1 is smaller than col1

-- inner or outer joins on foreign keys
SELECT * FROM Student;
SELECT * FROM House;

-- inner (only intersecting columns)
SELECT * FROM Student AS S JOIN -- same as typing INNER JOIN
House AS H ON S.House_ID = H.House_ID;
-- will output 2 columns for house id

-- USING() reuires columns to have the same name
SELECT * FROM Student JOIN House Using(House_ID);
-- output does not repeat the columns

-- outer join (non intersecting columns)
SELECT * FROM Student FULL JOIN House USING(House_ID);
-- returns extra row with nulls because there were no students in Hufflepuff

-- left join
SELECT * FROM Student LEFT JOIN House USING(House_ID);
-- of somebody was missing in house there would be NAs

-- right join
SELECT * FROM Student RIGHT JOIN House USING(House_ID);
-- filling missing data in students with NAs

--Practice adding a new table for snow cover
CREATE TABLE Snow_cover (
    Site VARCHAR NOT NULL,
    Year INTEGER NOT NULL CHECK (Year BETWEEN 1990 AND 2018),
    Date DATE NOT NULL,
    Plot VARCHAR NOT NULL,
    Location VARCHAR NOT NULL,
    Snow_cover REAL CHECK (Snow_cover BETWEEN 0 AND 130),
    Water_cover REAL CHECK (Water_cover BETWEEN 0 AND 130),
    Land_cover REAL CHECK (Land_cover BETWEEN 0 AND 130),
    Total_cover REAL CHECK (Total_cover BETWEEN 0 AND 130),
    Observer VARCHAR,
    Notes VARCHAR,
    PRIMARY KEY (Site, Plot, Location, Date),
    FOREIGN KEY (Site) REFERENCES Site (Code)
);

SELECT * FROM Snow_cover;
-- no data currently just empty rows

COPY Snow_cover FROM "ASDN_csv/snow_survey_fixed.csv" (header TRUE, nullstr "NA");

SELECT * FROM Snow_cover LIMIT 5;
-- worked there is data in the table now!

-- create temp table (live in database during that session)
CREATE TEMP TABLE Camp_assignment_copy AS
   SELECT * FROM Camp_assignment; 

SELECT Year, Site, Name FROM Camp_assignment_copy JOIN Personnel ON Observer = Abbreviation;

-- There is something even nicer than a temp table: VIEW (will remain in database until cleaned)
CREATE VIEW Camp_personnel_v AS
   SELECT Year, Site, Name 
   FROM Camp_assignment_copy JOIN Personnel ON Observer = Abbreviation;

--see all views in database
SELECT view_name FROM duckdb_views;

-- DANGER ZONE
-- when deleting something run conditional first to make sure you get what you actually want from the database

-- can remove things with DROP statement
