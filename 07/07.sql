drop table if exists input;
create table input (
  line serial primary key,
  value text not null
);

copy input (value) from '/aoc/07/input';

drop table if exists positions;
select string_to_table(value, ',')::integer as pos
  into positions
  from input;

-- part 1
with
  median as (
    select percentile_disc(0.5) within group (order by pos) as median
      from positions
  ),
  distances as (
    select abs(pos - median) as distance
      from positions cross join median
  )
select sum(distance) from distances;

-- part 2
with
  mean as (
    select round(avg(pos)) as mean
      from positions
  ),
  targets as (
    select generate_series(mean, mean+1) as target
      from mean
     union all
    select generate_series(mean-1, mean) as target
      from mean
  ),
  costs as (
    select target,
           abs(pos - target) * (abs(pos - target) + 1) / 2 as cost
      from positions cross join targets
  ),
  sums as (
    select target, sum(cost)::integer
      from costs
     group by target
  )
select min(sum) from sums;
