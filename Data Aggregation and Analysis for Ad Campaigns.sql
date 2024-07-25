with facebook_data as (
   select 
      ad_date,
      'Facebook Ads'as media_source,
      spend,
      impressions,
      reach,
      clicks,
      leads,
      value
   from facebook_ads_basic_daily
),
google_data as (
   select 
      ad_date,
      'Google Ads'as media_source,
      spend,
      impressions,
      reach,
      clicks,
      leads,
      value
  from google_ads_basic_daily
),
facebook_date_and_google_date as  (
  select 
     ad_date,
     media_source,
     spend,
     impressions,
     reach,
     clicks,
     leads,
     value
  from facebook_data
union all
select 
     ad_date,
     media_source,
     spend,
     impressions,
     reach,
     clicks,
     leads,
     value
from google_data
)
select
     ad_date,
     media_source,
     sum (spend) as total_spend,
     sum(impressions) as total_impressions,
     sum(reach) as total_reach,
     sum(clicks) as total_clicks,
     sum(leads) as total_leads,
     sum(value) as total_value
from facebook_date_and_google_date 
group by 1,2
order by 1,2;
