drop table if exists input;
create table input (
  line serial primary key,
  value text not null
);

copy input (value) from '/aoc/17/input';

drop table if exists target;
select v[1]::integer as x_min,
       v[2]::integer as x_max,
       v[3]::integer as y_min,
       v[4]::integer as y_max
  into target
  from input cross join regexp_match(value, 'target area: x=(-?\d+)..(-?\d+), y=(-?\d+)..(-?\d+)') v;

-- part 1
select (-y_min - 1) * (-y_min) / 2 as part1
  from target;

-- part 2
with recursive
  start_pos as (
    select x, y
      from generate_series(1, (select x_max from target)) xs(x)
           cross join generate_series((select y_min from target),
                                      (select -y_min from target)) ys(y)
  ),
  velocities as (
    select 0  as step,
           -1 as rel,
           x  as start_x,
           y  as start_y,
           x,
           y,
           0  as prev_x,
           0  as prev_y
      from start_pos
     union all
    select n.step+1,
           n.rel,
           n.start_x,
           n.start_y,
           n.x,
           n.y,
           n.prev_x,
           n.prev_y
      from (
        select v.step,
               v.start_x,
               v.start_y,
               (case
                when v.prev_x > t.x_max or v.prev_y < y_min then 1
                when v.prev_x >= t.x_min and v.prev_y <= t.y_max then 0
                else -1 end)  as rel,
               (case
                when v.x > 0 then v.x - 1
                else v.x end) as x,
               v.y - 1        as y,
               v.prev_x + v.x as prev_x,
               v.prev_y + v.y as prev_y
          from velocities v
               cross join target t
         where v.rel = -1
      ) as n
  ),
  initial_velocities as (
    select distinct start_x, start_y
      from velocities
     where rel = 0
  )
select count(*) as part2 from initial_velocities;
