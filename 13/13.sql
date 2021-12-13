drop table if exists input;
create table input (
  line serial primary key,
  value text not null
);

copy input (value) from '/aoc/13/input';

drop table if exists points;
select v[1]::integer as x,
       v[2]::integer as y
  into points
  from input cross join string_to_array(value, ',') v
 where value like '%,%';

drop table if exists instructions;
select row_number() over (order by line) as line,
       v[1]          as axis,
       v[2]::integer as val
  into instructions
  from input cross join regexp_match(value, '^fold along ([xy])=(\d+)$') v
 where value like 'fold along %';

with recursive
  folds (x, y, fold_num) as (
    select x,
           y,
           0 as fold_num
      from points
     union all
    select (case
            when i.axis = 'x' and f.x > i.val then i.val - (f.x - i.val)
            else f.x end) as x,
           (case
            when i.axis = 'y' and f.y > i.val then i.val - (f.y - i.val)
            else f.y end) as y,
           f.fold_num + 1
      from folds f inner join instructions i on f.fold_num + 1 = i.line
  ),
  part1 as (
    select count(*)
      from (select distinct x, y
              from folds
             where fold_num = 1) as _
  ),
  last_fold as (
    select *
      from folds
     where fold_num = 12
  ),
  max_vals as (
    select max(x) as max_x,
           max(y) as max_y
      from last_fold
  ),
  empty_grid as (
    select xs, ys
      from max_vals
           cross join generate_series(0, max_x) xs
           cross join generate_series(0, max_y) ys
  ),
  filled_grid as (
    select distinct e.xs,
                    e.ys,
                    (case
                     when f.x is null then '.'
                     else '#' end) as p_char
      from empty_grid e left outer join last_fold f on (e.xs = f.x and e.ys = f.y)
  ),
  part2 as (
    select ys,
           array_agg(p_char) as part2_chars
      from (select ys, p_char from filled_grid order by xs) as _
     group by ys
     order by ys
  )
select * from part1, part2;
