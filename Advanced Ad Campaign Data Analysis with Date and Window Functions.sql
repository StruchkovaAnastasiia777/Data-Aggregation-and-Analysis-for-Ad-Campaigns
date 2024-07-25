with combined_data1 as (

select 
   fd.ad_date,
   fd.url_parameters,
   coalesce(spend,0) as spend,
   coalesce(impressions,0) as impressions ,
   coalesce(reach,0) as reach ,
   coalesce(clicks,0)as clicks ,
   coalesce(leads,0) as leads ,
   coalesce(value,0) as value 
from
   facebook_ads_basic_daily fd 
left join 
   facebook_campaign fc on fc.campaign_id = fd.campaign_id
left join 
   facebook_adset fa  on fa.adset_id = fd.adset_id 

union all

select 
   gd.ad_date,
   gd.url_parameters,
   coalesce(spend,0) as spend,
   coalesce(impressions,0) as impressions ,
   coalesce(reach,0) as reach ,
   coalesce(clicks,0) as clicks ,
   coalesce(leads,0) as leads ,
   coalesce(value,0) as value 
from google_ads_basic_daily gd
),
combined_data2 as (
 select
   date_trunc('MONTH', ad_date) :: date as ad_month,
    case 
	   when urldecode_arr(lower(substring(url_parameters from 'utm_campaign=([^&]+)')))='nan' then null 
	   else urldecode_arr(lower(substring(url_parameters from 'utm_campaign=([^&]+)')))
	   end as utm_campaign,
   sum(spend) as total_spend,
   sum(impressions)as total_impressions,
   sum(clicks)as total_clicks,
   sum(value) as total_value,
   round(
     case 
     	when sum(impressions)>0 then (sum(clicks):: numeric/sum(impressions))*100 else 0
     end,2) as CTR,
     round(
     case 
     	when sum(clicks)>0 then sum(spend):: numeric/sum(clicks) else 0
     end,2) as CPC,
     round(
     case 
     	when sum(impressions)>0 then (sum(spend):: numeric/sum(impressions))*1000 else 0
     end,2) as CPM,
     round(
     case 
     	when sum(spend)>0 then ((sum(value):: numeric-sum(spend))/sum(spend))*100 else 0
     end,2) as ROMI
  from combined_data1 
  group by 1,2
),
 total_data as (
  select
        ad_month,
        utm_campaign,
        total_spend,
        total_impressions,
        total_clicks,
        total_value,
        CTR,
        CPC,
        CPM,
        ROMI,
        lag (CTR) over (partition by utm_campaign order by ad_month) as prev_CTR,
        lag (CPM) over (partition by utm_campaign order by ad_month) as prev_CPM,
        lag (ROMI) over (partition by utm_campaign order by ad_month) as prev_ROMI
  from combined_data2
)
  select
       ad_month,
        utm_campaign,
        total_spend,
        total_impressions,
        total_clicks,
        total_value,
        CTR,
        CPC,
        CPM,
        ROMI,
   round(
        case 
        when prev_CTR > 0 then (CTR/prev_CTR-1)*100 else null
        end,2) as Diff_CTR,
   round(
        case 
        when prev_CPM > 0 then (CPM/prev_CPM-1)*100 else null
        end,2) as Diff_CPM,
   round(
        case 
        when prev_ROMI > 0 then (ROMI/prev_ROMI-1)*100 else null
        end,2) as Diff_ROMI
  from total_data 
  order by 1,2;



