---conversion rates between key events by device category
WITH prep AS(
SELECT
device.category
---, device.mobile_brand_name
---, geo.country
, COUNTIF(event_name = 'page_view') AS page_view
, COUNTIF(event_name = 'add_to_cart') AS add_to_cart
, COUNTIF(event_name = 'purchase') AS purchase
FROM my-projects-475112.google_analytics_test.ga4_obfuscated_sample AS ga_4
GROUP BY device.category
---, mobile_brand_name
---, geo.country)
SELECT
category
---, mobile_brand_name
---, country)
, ROUND((SAFE_DIVIDE(add_to_cart, page_view))*100,2) AS cr_page_cart
, ROUND((SAFE_DIVIDE(purchase,add_to_cart))*100, 2) AS cr_cart_purchase
, ROUND((SAFE_DIVIDE(purchase,page_view))*100,2) AS cr_page_purchase
FROM prep;
---landing page/page title with highest add to cart events
WITH cte AS(
SELECT
event_date
, event_timestamp
, (SELECT value.string_value FROM UNNEST(event_params) WHERE key = "page_location") AS landing_page ---subquery to unnest landingpage
, (SELECT value.string_value FROM UNNEST(event_params) WHERE key = "page_title") AS page_title ---subquery to unnest pagetitle
FROM my-projects-475112.google_analytics_test.ga4_obfuscated_sample AS ga_4
WHERE event_name = 'add_to_cart')
SELECT
landing_page
, page_title
, COUNT(*) AS add_to_cart_events
FROM cte
GROUP BY landing_page, page_title
ORDER BY add_to_cart_events DESC

-----Write a query to find the top 5 landing pages by the number of sessions (or events) for each day.
SELECT
CAST(event_date AS DATE FORMAT 'YYYYMMDD') AS `date` -------format date
, (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') AS landing_page
, COUNT(*) AS nb_events
FROM my-projects-475112.google_analytics_test.ga4_obfuscated_sample AS ga4
GROUP BY `date`, landing_page
ORDER BY nb_events DESC
LIMIT 5;

----Calculate the percentage of total events that come from each device_category (e.g. mobile, desktop, tablet)
WITH events_device AS(
SELECT
device.category
, COUNT(*) AS nb_events
FROM my-projects-475112.google_analytics_test.ga4_obfuscated_sample AS ga4
GROUP BY device.category)
SELECT
category
, nb_events
, SUM(nb_events)OVER() AS total
, ROUND(nb_events/SUM(nb_events)OVER(),2) AS event_share
FROM events_device;
----Find the daily rank of countries based on total events.

WITH events_country AS(
SELECT
CAST(event_date AS DATE FORMAT 'YYYYMMDD') AS `date`
, geo.country
, COUNT(*) AS nb_events
FROM my-projects-475112.google_analytics_test.ga4_obfuscated_sample AS ga4
GROUP BY geo.country, `date`)
SELECT
`date`
, country
, RANK()OVER(PARTITION BY `date` ORDER BY nb_events DESC) AS rank
FROM events_country; ----“For each day, rank all countries by their number of events.”

---Write a query to find the cumulative number of events per device category over time.

WITH events_device AS(
SELECT
CAST(event_date AS DATE FORMAT 'YYYYMMDD') AS `date`
, device.category
, COUNT(*) AS nb_events 
FROM my-projects-475112.google_analytics_test.ga4_obfuscated_sample AS ga4
GROUP BY `date`, device.category)
SELECT
`date`
, category
, nb_events
, RANK()OVER(PARTITION BY `date` ORDER BY nb_events DESC) AS rank
FROM events_device

----If you had ecommerce data (like item_revenue and device_category), write a query to find average revenue per transaction per device type.

SELECT
event_date
, event_timestamp
, event_name
, device.category
, AVG(item_revenue)OVER(PARTITION BY device.category) AS avg_revenue
FROM my-projects-475112.google_analytics_test.ga4_obfuscated_sample AS ga4
, UNNEST(items) AS items
WHERE event_name = 'purchase'; 

----If you had product and location data (e.g. item_name, item_revenue, country), write a query to find the top 3 products by revenue in each country.

WITH revenue AS(
SELECT
i.item_name
, SUM(item_revenue) AS total_revenue
, geo.country
FROM my-projects-475112.google_analytics_test.ga4_obfuscated_sample AS ga4
, UNNEST(items) AS i 
GROUP BY item_name, country)
, ranking AS(
SELECT
item_name
, country
, DENSE_RANK()OVER(PARTITION BY country ORDER BY item_name DESC) AS rank
FROM revenue)
SELECT
item_name
, country
, rank 
FROM ranking
WHERE rank <= 3
ORDER BY country, rank;

----Find the total number of engaged sessions per device_category and country, and calculate the percentage share of engaged sessions per device within each country.

WITH sessions AS(
SELECT
geo.country
, device.category
, COUNTIF(value.string_value = '0') AS not_engaged
, COUNTIF(value.string_value = '1') AS engaged
, COUNTIF(value.string_value = '0') + COUNTIF(value.string_value = '1') AS total_sessions
, ROUND(COUNTIF(value.string_value = '1')/(COUNTIF(value.string_value = '0') + COUNTIF(value.string_value = '1')), 2) AS pct_engaged
FROM my-projects-475112.google_analytics_test.ga4_obfuscated_sample AS ga4
, UNNEST(event_params) AS ep
WHERE key = 'session_engaged'
GROUP BY geo.country, device.category)
SELECT
country
, category
, pct_engaged
FROM sessions