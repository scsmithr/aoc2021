drop table if exists input;
create table input (
  line serial primary key,
  value text not null
);

copy input (value) from '/aoc/05/input';

-- Parse line coordinates into a different table.
drop table if exists coords;
select line,
       groups[1]::integer as x1,
       groups[2]::integer as y1,
       groups[3]::integer as x2,
       groups[4]::integer as y2
  into coords
  from
    (select line, regexp_match(value, '^(\d+),(\d+) -> (\d+),(\d+)$') as groups
       from input) as _;

-- Horizontal or vertical lines.
select *
  from coords
 where x1 = x2 or y1 = y2;

-- Generate points for each line.
with recursive
  points (x1, y1, x2, y2, curr_x, curr_y) as (
    -- Starting point for a line.
    select x1, y1, x2, y2, x1, y1
      from coords
             union all
      -- Walk from beginning to end.
    select x1, y1, x2, y2,
           (case when curr_x < x2 then curr_x + 1
            when curr_x > x2 then curr_x - 1
            else curr_x end) as curr_x,
           (case when curr_y < y2 then curr_y + 1
            when curr_y > y2 then curr_y - 1
            else curr_y end) as curr_y
      from points
     where curr_x != x2 or curr_y != y2
  ),
  -- Count points from overlapping horizontal or vertical lines.
  counts1 as (
    select count(*)
      from points
     where x1 = x2 or y1 = y2
     group by curr_x, curr_y
  ),
  part1 as (
    select count(*)
      from counts1 c
     where c.count > 1
  ),
  -- Count points from overlapping horizontal, vertical, or diagonal lines.
  counts2 as (
    select count(*)
      from points
     group by curr_x, curr_y
  ),
  part2 as (
    select count(*)
      from counts2 c
     where c.count > 1
  )
select * from part1, part2;
