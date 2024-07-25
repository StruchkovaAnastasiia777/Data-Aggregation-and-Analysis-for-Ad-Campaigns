with combined_data1 as(

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

select gd.ad_date,
   gd.url_parameters,
   coalesce(spend,0) as spend,
   coalesce(impressions,0) as impressions ,
   coalesce(reach,0) as reach ,
   coalesce(clicks,0) as clicks ,
   coalesce(leads,0) as leads ,
   coalesce(value,0) as value 
from google_ads_basic_daily gd
)
select
   ad_date,
      case 
	   when urldecode_arr(lower(substring(url_parameters from 'utm_campaign=([^&]+)')))='nan' then null 
	   else urldecode_arr(lower(substring(url_parameters from 'utm_campaign=([^&]+)')))
	   end utm_campaign,
   sum(spend) as total_spend,
   sum(impressions)as total_impressions,
   sum(clicks)as total_clicks,
   sum(value) as total_value,
   round(
     case 
     	when sum(impressions)>0 then (sum(clicks):: numeric/sum(impressions))*100 else 0
     end,2) ||'%'as CPR,
     round(
     case 
     	when sum(clicks)>0 then sum(spend):: numeric/sum(clicks) else 0
     end,2) ||'$'as CPC,
     round(
     case 
     	when sum(impressions)>0 then (sum(spend):: numeric/sum(impressions))*1000 else 0
     end,2) ||'$'as CPM,
     round(
     case 
     	when sum(spend)>0 then ((sum(value):: numeric-sum(spend))/sum(spend))*100 else 0
     end,2) ||'%'as ROMI
from combined_data1 
group by 1,2
order by 1,2
