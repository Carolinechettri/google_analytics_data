SELECT 
visitId
, PARSE_DATE('%Y%m%d', `date`) AS `date`
, ROUND(SAFE_DIVIDE(`time`, 60000),2) AS mins_spent
, CONCAT(CAST(hour AS STRING), ":", LPAD(CAST(minute AS STRING),2,'0')) AS `time`
, page.pagePath
, page.pageTitle
FROM `my-projects-475112.google_analytics_test.ga_sessions_raw`
, UNNEST(hits) AS hit