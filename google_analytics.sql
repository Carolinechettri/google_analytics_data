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
