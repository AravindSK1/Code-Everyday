# 1: MoM percentage Change

/*
*Context:* Oftentimes it's useful to know how much a key metric,
such as monthly active users, changes between months.
Say we have a table logins in the form:

| user_id | date       |
|---------|------------|
| 1       | 2018-07-01 |
| 234     | 2018-07-02 |
| 3       | 2018-07-02 |
| 1       | 2018-07-02 |
| ...     | ...        |
| 234     | 2018-10-04 |

*Task*: Find the month-over-month percentage change for monthly active users (MAU).
*/

# Solution:

/* Variant 1  - for data in the same year */
WITH mau AS
(
  SELECT
    MONTH(date) as mnth,
    COUNT(DISTINCT user_id) as MAU
    FROM
      logins
    GROUP BY
      MONTH(date)
)

SELECT
  a.mnth as previous_month,
  a.MAU as previous_mau,
  b.mnth as current_month,
  b.MAU as current_mau
  ROUND(100.0 * (b.mau - a.mau)/a.mau, 2) as percentage_change
FROM
  mau a
JOIN
  mau b ON a.mnth = b.mnth - 1 /* Get's the previous month with b as the current month*/

/* Variant 2  - for data with different year */
WITH mau AS
(
  SELECT
    YEAR(date) * 100 + MONTH(date) AS year_mnth,
    COUNT(DISTINT user_id) as MAU
    FROM
      logins
    GROUP BY
      YEAR(date) * 100 + MONTH(date)
)
SELECT
  a.year_mnth as previous_year_mth,
  a.MAU as previous_mau,
  b.year_mnth as current_year_mth,
  b.MAU as current_mau,
  ROUND(100.0 * (b.MAU - a.MAU)/a.MAU,2) as percentage_change
FROM
  mau a
JOIN
  mau b on a.year_mnth = CASE WHEN MONTH(b.date) == 1
                              THEN b.year_mnth - 89
                              ELSE b.year_mnth - 1
                         END /* Get's the previous month with b as the current month*/

--------------------------------
# 2: Tree Structure Lableing
--------------------------------

/*
*Context:* Say you have a table tree with a column of nodes and a column corresponding parent nodes

node   parent
1       2
2       5
3       5
4       3
5       NULL

*Task:* Write SQL such that we label each node as a “leaf”, “inner” or “Root” node, such that for the nodes above we get:

node    label
1       Leaf
2       Inner
3       Inner
4       Leaf
5       Root

A solution which works for the above example will receive full credit, although you can receive extra credit for providing a solution that is generalizable to a tree of any depth (not just depth = 2, as is the case in the example above).
*/
# Solution:

SELECT
  CASE WHEN a.parent is null then "Root"
       WHEN b.node in a.parent then "Inner"
       WHEN b.node not in a.parent then "Leaf"
  END as label
  FROM
    tree a
  JOIN
    tree b ON a.node = b.node

------------------------------------------
# 3: Retained Users Per Month (multi-part)
------------------------------------------

/*
Part 1:

*Context:* Say we have login data in the table logins:

| user_id | date       |
|---------|------------|
| 1       | 2018-07-01 |
| 234     | 2018-07-02 |
| 3       | 2018-07-02 |
| 1       | 2018-07-02 |
| ...     | ...        |
| 234     | 2018-10-04 |

*Task:* Write a query that gets the number of retained users per month. In this case,
retention for a given month is defined as the number of users who logged in that month who also logged in the immediately previous month.
*/
--Get the unique users-login pair
WITH UniqueMonthlyUsers AS
(
  /*
  * For each month, compute the *set* of users having logins.
  */
  SELECT
    YEAR(date) yr,
    MONTH(date) mnth,
    YEAR(date) * 100 + MONTH(date) as yr_mnth,
    user_id
  FROM
    login
  GROUP BY
    YEAR(date) yr,
    MONTH(date) mnth,
    user_id
)
SELECT
  current_month.yr_mnth,
  COUNT(DISTINCT current_month.user_id) monthly_users
FROM
  UniqueMonthlyUsers AS previous_month
JOIN
  UniqueMonthlyUsers AS current_month
  ON previous_month.yr_mnth = CASE
                                  WHEN current_month.mnth == 1 THEN current_month.yr_mnth - 89
                                  ELSE current_month.yr_mnth - 1
                              END
  AND previous_month.user_id = current_month.user_id
GROUP BY
  current_month.yr_mnth

/*
  Part 2:

  *Task:* Now we’ll take retention and turn it on its head: Write a query to find many users last month did not come back this month. i.e. the number of churned users.
*/

WITH UniqueMonthlyUsers AS
(
  /*
  * For each month, compute the *set* of users having logins.
  */
  SELECT
    YEAR(date) yr,
    MONTH(date) mnth,
    YEAR(date) * 100 + MONTH(date) as yr_mnth,
    user_id
  FROM
    login
  GROUP BY
    YEAR(date) yr,
    MONTH(date) mnth,
    user_id
)
SELECT
  current_month.yr_mnth,
  COUNT(DISTINCT current_month.user_id) churned_users
FROM
  UniqueMonthlyUsers AS previous_month
FULL OUTER JOIN
  UniqueMonthlyUsers AS current_month
  ON previous_month.yr_mnth = CASE
                                  WHEN current_month.mnth == 1 THEN current_month.yr_mnth - 89
                                  ELSE current_month.yr_mnth - 1
                              END
  AND previous_month.user_id = current_month.user_id
GROUP BY
  current_month.yr_mnth


------------------------------------------
# 4: Cumulative Sums
------------------------------------------
/*
*Context:* Say we have a table transactions in the form:

| date       | cash_flow |
|------------|-----------|
| 2018-01-01 | -1000     |
| 2018-01-02 | -100      |
| 2018-01-03 | 50        |
| ...        | ...       |

Where cash_flow is the revenues minus costs for each day.

*Task:* Write a query to get cumulative cash flow for each day such that we end up with a table in the form below:

| date       | cumulative_cf |
|------------|---------------|
| 2018-01-01 | -1000         |
| 2018-01-02 | -1100         |
| 2018-01-03 | -1050         |
| ...        | ...           |
*/

SELECT
  date,
  SUM(cash_flow) OVER(ORDER BY date ASC) as cumulative_cf -- Partition by is removed here inorder to consider all the dataset for cumulative sum. If needed we can calculate sum() over (partition by month(date) order by date asc) for getting the cumulative sum each month
FROM
  transactions
ORDER BY
  date ASC

------------------------------------------
# 5: Rolling Averages
------------------------------------------
/*
*Acknowledgement:* This problem is adapted from Sisense’s “Rolling Averages in MySQL and SQL Server” (https://www.sisense.com/blog/rolling-average/) blog post

*Note:* there are different ways to compute rolling/moving averages. Here we'll use a preceding average which means that the metric for the 7th day of the month would be the average of the preceding 6 days and that day itself.

*Context*: Say we have table signups in the form:

| date       | sign_ups |
|------------|----------|
| 2018-01-01 | 10       |
| 2018-01-02 | 20       |
| 2018-01-03 | 50       |
| ...        | ...      |
| 2018-10-01 | 35       |

*Task*: Write a query to get 7-day rolling (preceding) average of daily sign ups.
*/

-- Version 1
SELECT
  a.date,
  AVG(b.sign_ups) average_sign_ups
FROM
  signups a
JOIN
  signups b ON a.date <= b.date + INTERVAL 6 DAY AND a.date >= b.date
GROUP BY
  a.date

-- Version 2
SELECT
  date,
  AVG(sign_ups) over (ORDER BY date ROWS BETWEEN 6 PRECEDING AND 0 PRECEDING)
FROM
  signups

------------------------------------------
# 6: Multiple Join Conditions
------------------------------------------
/*
*Acknowledgement:* This problem was inspired by Sisense’s “Analyzing Your Email with SQL” (https://www.sisense.com/blog/analyzing-your-email-with-sql/) blog post

*Context:* Say we have a table emails that includes emails sent to and from zach@g.com:

| id | subject  | from         | to           | timestamp           |
|----|----------|--------------|--------------|---------------------|
| 1  | Yosemite | zach@g.com   | thomas@g.com | 2018-01-02 12:45:03 |
| 2  | Big Sur  | sarah@g.com  | thomas@g.com | 2018-01-02 16:30:01 |
| 3  | Yosemite | thomas@g.com | zach@g.com   | 2018-01-02 16:35:04 |
| 4  | Running  | jill@g.com   | zach@g.com   | 2018-01-03 08:12:45 |
| 5  | Yosemite | zach@g.com   | thomas@g.com | 2018-01-03 14:02:01 |
| 6  | Yosemite | thomas@g.com | zach@g.com   | 2018-01-03 15:01:05 |
| .. | ..       | ..           | ..           | ..                  |

*Task:* Write a query to get the response time per email (id) sent to zach@g.com .
Do not include ids that did not receive a response from zach@g.com.
Assume each email thread has a unique subject.
Keep in mind a thread may have multiple responses back-and-forth between zach@g.com and another email address
*/

-- What is response time? It is the first instance someone responses to an email
SELECT
  a.id,
  MIN(b.timestamp) - a.timestamp AS response_time
FROM
  emails a
JOIN
  emails b
  ON  a.subject = b.subject
  AND a.from = b.to
  AND a.to = b.from
  AND a.timestamp < b.timestamp -- this eliminates future replies
WHERE
  a.to = "zach@g.com"
GROUP BY
  a.id

----------------------------------------------------------------------------------------------------------------------------------------------------------------
  ########################################################### Window Function Practice Problems ###########################################################
----------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------
# 1: Get the ID with the highest value
------------------------------------------
/*
*Context:* Say we have a table salaries with data on employee salary and department in the following format:

  depname  | empno | salary |
-----------+-------+--------+
 develop   |    11 |   5200 |
 develop   |     7 |   4200 |
 develop   |     9 |   4500 |
 develop   |     8 |   6000 |
 develop   |    10 |   5200 |
 personnel |     5 |   3500 |
 personnel |     2 |   3900 |
 sales     |     3 |   4800 |
 sales     |     1 |   5000 |
 sales     |     4 |   4800 |

*Task*: Write a query to get the empno with the highest salary. Make sure your solution can handle ties!
*/
WITH salary_rank AS
(
  SELECT
    empno,
    RANK() OVER(ORDER BY salary DESC) as rnk
  FROM
    salaries
)
SELECT
  empno
FROM
  salary_rank
WHERE
  rnk = 1;

---------------------------------------------
# 2: Average and Rank with a window function
---------------------------------------------
/*
Part 1:

*Context*: Say we have a table salaries in the format:

  depname  | empno | salary |
-----------+-------+--------+
 develop   |    11 |   5200 |
 develop   |     7 |   4200 |
 develop   |     9 |   4500 |
 develop   |     8 |   6000 |
 develop   |    10 |   5200 |
 personnel |     5 |   3500 |
 personnel |     2 |   3900 |
 sales     |     3 |   4800 |
 sales     |     1 |   5000 |
 sales     |     4 |   4800 |

*Task:* Write a query that returns the same table, but with a new column that has average salary per depname. We would expect a table in the form:

  depname  | empno | salary | avg_salary |
-----------+-------+--------+------------+
 develop   |    11 |   5200 |       5020 |
 develop   |     7 |   4200 |       5020 |
 develop   |     9 |   4500 |       5020 |
 develop   |     8 |   6000 |       5020 |
 develop   |    10 |   5200 |       5020 |
 personnel |     5 |   3500 |       3700 |
 personnel |     2 |   3900 |       3700 |
 sales     |     3 |   4800 |       4867 |
 sales     |     1 |   5000 |       4867 |
 sales     |     4 |   4800 |       4867 |
*/

SELECT
  *,
  ROUND(AVG(salary),0) over(PARTITION BY depname) AS avg_salary -- this rounds to 0 decimal places
FROM
  salaries

/*
Part 2:

*Task:* Write a query that adds a column with the rank of each employee based on their salary within their department,
where the employee with the highest salary gets the rank of 1. We would expect a table in the form:

  depname  | empno | salary | salary_rank |
-----------+-------+--------+-------------+
 develop   |    11 |   5200 |           2 |
 develop   |     7 |   4200 |           5 |
 develop   |     9 |   4500 |           4 |
 develop   |     8 |   6000 |           1 |
 develop   |    10 |   5200 |           2 |
 personnel |     5 |   3500 |           2 |
 personnel |     2 |   3900 |           1 |
 sales     |     3 |   4800 |           2 |
 sales     |     1 |   5000 |           1 |
 sales     |     4 |   4800 |           2 |
*/

SELECT
  *,
  RANK() OVER(PARTITION BY depname ORDER BY salary DESC) salary_rank
FROM
  salaries

----------------------------------------------------------------------------------------------------------------------------------------------------------------
########################################################### Other Medium/Hard SQL Practice Problems ###########################################################
----------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------
# 1: Histograms
------------------------------------------
/*
*Context:* Say we have a table sessions where each row is a video streaming session with length in seconds:

| session_id | length_seconds |
|------------|----------------|
| 1          | 23             |
| 2          | 453            |
| 3          | 27             |
| ..         | ..             |

*Task:* Write a query to count the number of sessions that fall into bands of size 5, i.e. for the above snippet, produce something akin to:

| bucket  | count |
|---------|-------|
| 20-25   | 2     |
| 450-455 | 1     |

Get complete credit for the proper string labels (“5-10”, etc.) but near complete credit for something that is communicable as the bin.
*/

WITH bin_label AS
(
  SELECT
    session_id,
    FLOOR(length_seconds/5) AS bin
  FROM
    sessions
)
SELECT
  CONCATENATE(STR(bin*5), '-', STR(bin*5+5)) AS bucket,
  COUNT(DISTINCT session_id) AS count
FROM
  bin_label
GROUP BY
  bin
ORDER BY
  bin ASC

------------------------------------------
#2: CROSS JOIN (multi-part)
------------------------------------------

/*
Part 1:

*Context:* Say we have a table state_streams where each row is a state and the total number of hours of streaming from a video hosting service:

| state | total_streams |
|-------|---------------|
| NC    | 34569         |
| SC    | 33999         |
| CA    | 98324         |
| MA    | 19345         |
| ..    | ..            |

(In reality these kinds of aggregate tables would normally have a date column, but we’ll exclude that component in this problem)

*Task:* Write a query to get the pairs of states with total streaming amounts within 1000 of each other. For the snippet above, we would want to see something like:

| state_a | state_b |
|---------|---------|
| NC      | SC      |
| SC      | NC      |

*/

SELECT
  a.state AS state_a,
  b.state AS state_b
FROM
  state_streams a, state_streams b
WHERE
  ABS(a.total_streams - b.total_streams) < 1000
  AND
  a.state <> b.state

/*
Part 2:

*Note:* This question is considered more of a bonus problem than an actual SQL pattern. Feel free to skip it!

*Task:* How could you modify the SQL from the solution to Part 1 of this question so that duplicates are removed?
For example, if we used the sample table from Part 1, the pair NC and SC should only appear in one row instead of two.
*/

SELECT
  a.state as state_a,
  b.state as state_b
FROM
  state_streams a, state_streams b
WHERE
  ABS(a.total_streams - b.total_streams) < 1000
  AND
  a.state > b.state
