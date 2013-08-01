--------------------------------------------------------------------------------
--                            missing_subscription                            --
--------------------------------------------------------------------------------
create view missing_subscription as
select null::varchar(32) as guid, tp.customer_guid, null::varchar as customer_id, tp.partner, tp.country, timestamp '2013-07-03 02:00' as start_time, 2::smallint as subscription, 'PAYING' as royalty_classification
from track_play tp
left join subscription s on s.customer_guid = tp.customer_guid
where s.guid is null
and tp.reported_time > timestamp '2013-07-03'
and play_duration > 30
group by tp.customer_guid, tp.partner, tp.country;

--------------------------------------------------------------------------------
--                             guvera_subscription                            --
--------------------------------------------------------------------------------
create or replace view guvera_subscription as
select guid, customer_guid, customer_id, partner, country, start_time, subscription,
case when start_time < timestamp '2013-07-03 01:00'
       or (
                start_time > timestamp '2013-07-03 01:00'
            and start_time < timestamp '2013-07-05'
            and (customer_id like 'T_%' and (customer_id not like 'T_GUVERATEST_%' or customer_id in ('T_GUVERATEST_6632', 'T_GUVERATEST_66347', 'T_GUVERATEST_684811')))
          )
       or (
                start_time > timestamp '2013-07-05'
            and customer_id like 'T_%'
          )
     then 'TEST'
     else 'PAYING' end as royalty_classification
from subscription
union
select * from missing_subscription;

