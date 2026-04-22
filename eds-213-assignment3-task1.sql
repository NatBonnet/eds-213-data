--Suppose you’re not sure what the AVG function returns if there are NULL values in the column being averaged. 
--Suppose you either didn’t have access to any documentation, or didn’t trust it. 
--What experiment could you run to find out what happens?

--preview all tables in database
.table

--create temp table from birds database
CREATE TEMP TABLE temp_table AS
SELECT egg_num
FROM Bird_eggs;

-- try inserting one row with a NULL value
INSERT INTO temp_table (egg_num)
VALUES(NULL);

-- try inserting multiple numeric values and another null value
INSERT INTO temp_table (egg_num)
VALUES(3, 6, 5, NULL);

--This doesn't work!
--Column name/value mismatch for insert on temp_table: expected 1 columns but 4 values were supplied

-- Need to seperate values with parentheses
INSERT INTO temp_table (egg_num)
VALUES(3), (6), (5), (NULL);
-- This works!

-- Try averaging column with nulls inside
SELECT avg(egg_num) FROM temp_table;

--What would the average be if the function ignored NULLs? 
SELECT avg(egg_num) FROM temp_table WHERE egg_num IS NOT NULL;
-- same value 

--What would the average be if it somehow factored them in? 
SELECT avg(COALESCE(egg_num, 0))
FROM temp_table; 
--What is actually returned?
┌───────────────────┬───────────────────────────┐
│   avg(egg_num)    │ avg(COALESCE(egg_num, 0)) │
│      double       │          double           │
├───────────────────┼───────────────────────────┤
│ 2.447432762836186 │         2.435523114355231 │
└───────────────────┴───────────────────────────┘


--Conclusion:

--AVG() takes the sum of all non null values in the column and divides by the number of values.

--Using coalesce() coerces NA values to be equal to 0 so they do not contribute to to summed value, and are counted in the number that in the denominator.


--Task 2

SELECT Site_name, MAX(Area) FROM Site;


--MAX(Area) collapses all rows into a single value (the maximum), where Site_name is a row-level value. 
--There are as many site names as there are rows, so the the query makes it unclear which site should be attached to that single value.


--Time for plan B. Find the site name and area of the site having the largest area. Do so by ordering the rows in a particularly convenient order, and using LIMIT to select just the first row. Your result should look like:

SELECT Site_name, Area
FROM Site
ORDER BY Area DESC
LIMIT 1;

┌──────────────┬────────┐
│  Site_name   │  Area  │
│   varchar    │ float  │
├──────────────┼────────┤
│ Coats Island │ 1239.1 │
└──────────────┴────────┘

-- Part 3
-- the same, but use a nested query. 
--First, create a query that finds the maximum area. T
--then, create a query that selects the site name and area of the site whose area equals the maximum. 
--Your overall query will look something like:

SELECT Site_name, Area 
FROM Site 
WHERE Area = (SELECT MAX(Area) FROM Site);

┌──────────────┬────────┐
│  Site_name   │  Area  │
│   varchar    │ float  │
├──────────────┼────────┤
│ Coats Island │ 1239.1 │
└──────────────┴────────┘

--Task 3
--Your mission is to list the scientific names of bird species in descending order 
--of their maximum average egg volumes. That is, compute the average volume of the eggs in each nest, 
--and then for the nests of each species compute the maximum of those average volumes, 
--and list by species in descending order of maximum volume. You final table should look like:


--A good place to start is just to group bird eggs by nest (i.e., Nest_ID) and compute average volumes:

CREATE TEMP TABLE Averages AS
    SELECT Nest_ID, AVG(3.14/6 * Length^2 * Width) AS Avg_volume
        FROM Bird_eggs
        GROUP BY Nest_ID;

--You can now join that table with Bird_nests, 
--so that you can group by species, and also join with the Species table to pick up scientific names. 
--To do just the first of those joins, you could say something like

SELECT Species, MAX(...)
    FROM Bird_nests JOIN Averages USING (Nest_ID)
    GROUP BY ...;

--(Notice how, if the joined columns have the same name, you can more compactly say USING (common_column) 
--instead of ON column_a = column_b.)

That’s not the whole story, we want scientific names not species codes. Another join is needed. A couple strategies here. One, you can modify the above query to also join with the Species table (you’ll need to replace USING with ON …). Two, you can save the above as another temp table and join it to Species separately.

Don’t forget to order the results. Here it is convenient to give computed quantities nice names so you can refer to them.

Please submit all of the SQL you used to solve the problem.

┌─────────────────────────┬────────────────────┐
│     Scientific_name     │   Max_avg_volume   │
│         varchar         │       double       │
├─────────────────────────┼────────────────────┤
│ Pluvialis squatarola    │   36541.8525390625 │
│ Pluvialis dominica      │    33847.853515625 │
│ Arenaria interpres      │   23338.6220703125 │
│ Calidris fuscicollis    │ 13277.143310546875 │
│ Calidris alpina         │ 12196.237548828125 │
│ Charadrius semipalmatus │ 11266.974975585938 │
│ Phalaropus fulicarius   │  8906.775146484375 │
└─────────────────────────┴────────────────────┘

SELECT Scientific_name, Max_avg_volume
FROM Bird_nests