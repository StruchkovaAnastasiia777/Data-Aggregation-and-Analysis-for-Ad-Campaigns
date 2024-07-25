with facebook_google_total  as (
   select  
   fd.ad_date,
   c.campaign_name,
    'Facebook Ads' as media_source,
   fa.adset_name,
   sum(fd.spend)as total_spend,
   sum (fd.impressions) as total_impressions,
   sum(fd.reach) as total_reach,
   sum(fd.clicks) as total_clicks,
   sum(fd.leads)as total_leads,
   sum(fd.value) as total_value
   from facebook_ads_basic_daily fd
   left join facebook_campaign c on fd.campaign_id = c.campaign_id
   inner join facebook_adset fa on fd.adset_id = fa.adset_id
   group by 1,2,3,4
   
   union all
   
   select gd.ad_date,
  'Google Ads'as media_source,
   gd.campaign_name,
   gd.adset_name,
   sum(gd.spend)as total_spend,
   sum (gd.impressions) as total_impressions,
   sum(gd.reach) as total_reach,
   sum(gd.clicks) as total_clicks,
   sum(gd.leads)as total_leads,
   sum(gd.value) as total_value
 from google_ads_basic_daily gd
 group by 1,2,3,4
   ) 
   select ad_date,
 media_source,
 campaign_name,
 adset_name,
 total_spend,
 total_impressions,
 total_clicks,
 total_value
from facebook_google_total 