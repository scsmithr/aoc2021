drop table if exists input;
create table input (
  line serial primary key,
  value text not null
);

copy input (value) from '/aoc/09/input';

drop table if exists points;
select ordinality as x,
       line       as y,
       val::integer
  into points
  from input
       cross join lateral unnest(string_to_array(value, null)) with ordinality val;

-- For part 2
create or replace aggregate mul(integer) (sfunc=int4mul, stype=integer);

with recursive
  adjacents as (
    select p1.x,
           p1.y,
           p1.val,
           p2.val as left_val,
           p3.val as right_val,
           p4.val as up_val,
           p5.val as down_val
      from points p1
           left outer join points p2 on (p1.x - 1 = p2.x and p1.y     = p2.y)
           left outer join points p3 on (p1.x + 1 = p3.x and p1.y     = p3.y)
           left outer join points p4 on (p1.x     = p4.x and p1.y - 1 = p4.y)
           left outer join points p5 on (p1.x     = p5.x and p1.y + 1 = p5.y)
  ),
  low_points as (
    select x,
           y,
           val
      from adjacents
     where (val < left_val or left_val is null)
       and (val < right_val or right_val is null)
       and (val < up_val or up_val is null)
       and (val < down_val or down_val is null)
  ),
  part1 as (
    select sum(val+1)
      from low_points
  ),
  basins(start_x, start_y, curr_x,  curr_y, curr_val, visited, cycle) as (
    select p.x                  as start_x,
           p.y                  as start_y,
           p.x                  as curr_x,
           p.y                  as curr_y,
           p.val                as curr_val,
           array[row(p.x, p.y)] as visited,
           false                as cycle
      from low_points p
           inner join adjacents a on (p.x = a.x and p.y = a.y)
     union all
    select b.start_x,
           b.start_y,
           a.x                            as curr_x,
           a.y                            as curr_y,
           a.val                          as curr_val,
           b.visited || row(a.x, a.y)     as visited,
           row(a.x, a.y) = any(b.visited) as cycle
      from basins b
           inner join adjacents a on
                        (a.val > b.curr_val
                        and ((b.curr_x + 1    = a.x and b.curr_y     = a.y)
                             or (b.curr_x - 1 = a.x and b.curr_y     = a.y)
                             or (b.curr_x     = a.x and b.curr_y - 1 = a.y)
                             or (b.curr_x     = a.x and b.curr_y + 1 = a.y))
                             and not cycle
                             and a.val != 9)
  ),
  distinct_basins as (
    select distinct start_x,
                    start_y,
                    curr_x,
                    curr_y,
                    curr_val
      from basins
  ),
  basin_sizes as (
    select start_x,
           start_y,
           count(*) as basin_size
      from distinct_basins
     group by start_x, start_y
  ),
  part2 as (
    select mul(basin_size::integer)
      from (select * from basin_sizes order by basin_size desc limit 3) as _
  )
select * from part1, part2;
