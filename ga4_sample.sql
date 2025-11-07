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
---key finding: 100% of apple tablet users who added to cart ended up purchasing