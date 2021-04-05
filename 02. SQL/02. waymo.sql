
+--------------------------------+---------+
| customer_id                    | int     |<--+
| business_or_personal_account   | varchar |   |
+--------------------------------+---------+   |
                         |
rides                                          |
+--------------------------------+---------+   |
| ride_id                        | int     |   |
| date                           | date    |   |
| customer_id                    | int     |<--+
| ride_miles                     | int     |
| ride_minutes                   | int     |
| would_customer_recommend_waymo | varchar | *Can be 'yes','no',or NULL
+--------------------------------+------


/* 2. What is the average number of days from when a customer takes one ride to the next ride,
as averaged over all rides that have a future ride?  (for example:
if a customer takes rides on 1/1, 1/15, 1/15 and another customer takes rides on 1/10, 1/14,
then we would average together [14,0,4] = 6) */

With adjacent_rides as
(
select *
, lead(date, 1,'2100-01-01') over (partition by customer_id order by date asc) as next_ride
from rides
)
select adjacent_rides.customer_id
, timestampdiff(day, adjacent_rides.next_ride, adjacent_rides.date) as number_of_days
from adjacent_rides
where adjacent_rides.date != '2100-01-01'

/* Let’s say we define an inactive customer as any customer who has not taken any rides in the last 3 months. */

/* 3. How many customers were inactive as of November 30, 2020? */

with second_recent_ride as
(select customer_id,
date,
rank() over (partition by customer_id order by date desc) as rank_ride
from rides where date <= '2019-11-30')

select count(distinct customer_id)
from
(SELECT
   rank1.customer_id,timestampdiff(day,date_2,date)as date_diff
FROM
    second_recent_ride rank1
        LEFT JOIN
    (SELECT
        customer_id, date AS date_2
    FROM
        second_recent_ride
    WHERE
        rank_ride = 2) rank2 ON rank1.customer_id = rank2.customer_id
WHERE
    rank_ride = 1 )A1
where date_diff>90;

/* The Marketing Manager decided to reach out to the inactive customers to try to get them to use Waymo again.
On December 1, 2020, she sent an email to the inactive customers identified in question 3 to tell them about Waymo’s newest features
and encourage them to take a ride. */

/* 4. In the next month (December 1-31, 2020), what percent of those previously inactive customers (per question 3) took a ride in a Waymo? */



/* 5. Was this email campaign successful?  Do you have any concerns?
What recommendations would you make to the Marketing Manager about the best way to roll out future campaigns so that we can evaluate success? */
