SELECT
visitId
, `date`
, channelGrouping
, page.pagePath
, trafficSource.source
, device.deviceCategory
, geoNetwork.country
FROM `my-projects-475112.google_analytics_test.ga_sessions_raw`
, UNNEST(hits)
---add volume of users/country
SELECT
  COUNT(visitId) AS nb_visitors,
  geoNetwork.country,
  product.v2ProductCategory
FROM `my-projects-475112.google_analytics_test.ga_sessions_raw`
, UNNEST(hits) AS hit
, UNNEST(hit.product) AS product
GROUP BY geoNetwork.country, product.v2ProductCategory
ORDER BY nb_visitors DESC