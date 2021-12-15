drop table if exists input;
create table input (
  line serial primary key,
  value text not null
);

copy input (value) from '/aoc/15/input';

drop table if exists points;
select ord::integer  as x,
       line::integer as y,
       val::integer
  into points
  from input
       cross join unnest(string_to_array(value, null)) with ordinality _(val, ord);

-- part 1
with recursive
  basis as (
    select sum(val) as basis
      from points
     where x = (select min(x) from points)
        or y = (select max(y) from points)
  ),
  costs as (
    select (case (x, y)
            when (1, 1) then 0
            else basis end) as total,
           val,
           x,
           y
      from points cross join basis
     union all
    select t.total,
           t.val,
           t.x,
           t.y
      from (
        with
          initial_costs as (select * from costs),
          min_total as (
            select total, val, x, y
              from initial_costs
             order by total
             limit 1
          ),
          surrounding_costs as (
            select (case
                    when m.total + i.val < i.total then m.total + i.val
                    else i.total end) as total,
                   i.val,
                   i.x,
                   i.y
              from initial_costs i
                   inner join min_total m on (i.x - m.x, i.y - m.y) in ((-1, 0), (0, -1), (1, 0), (0, 1))
          ),
          updated_costs as (
            select coalesce(s.total, i.total) as total,
                   i.val,
                   i.x,
                   i.y
              from initial_costs i
                   left outer join surrounding_costs s on (i.x, i.y) = (s.x, s.y)
                   cross join min_total m
             where (m.x, m.y) != (i.x, i.y)
          )
        select * from updated_costs
      ) as t
  ),
  part1 as (
    select min(total)
      from costs
     where x = (select max(x) from points)
       and y = (select max(y) from points)
  )
select * from part1;

-- part 2
with recursive
  tiled_rows as (
    select (case
            when p.val + i > 9 then i
            else p.val + i end) as val,
           x * i + x as x,
           y
      from points p
           cross join generate_series(0, 4) i
  ),
  tiled as (
    select (case
            when p.val + i > 9 then i
            else p.val + i end) as val,
           x,
           y * i + y as y
      from tiled_rows p
           cross join generate_series(0, 4) i
  ),
  basis as (
    select sum(val) as basis
      from tiled
     where x = (select min(x) from tiled)
        or y = (select max(y) from tiled)
  ),
  costs as (
    select (case (x, y)
            when (1, 1) then 0
            else basis end) as total,
           val,
           x,
           y
      from tiled cross join basis
     union all
    select t.total,
           t.val,
           t.x,
           t.y
      from (
        with
          initial_costs as (select * from costs),
          min_total as (
            select total, val, x, y
              from initial_costs
             order by total
             limit 1
          ),
          surrounding_costs as (
            select (case
                    when m.total + i.val < i.total then m.total + i.val
                    else i.total end) as total,
                   i.val,
                   i.x,
                   i.y
              from initial_costs i
                   inner join min_total m on (i.x - m.x, i.y - m.y) in ((-1, 0), (0, -1), (1, 0), (0, 1))
          ),
          updated_costs as (
            select coalesce(s.total, i.total) as total,
                   i.val,
                   i.x,
                   i.y
              from initial_costs i
                   left outer join surrounding_costs s on (i.x, i.y) = (s.x, s.y)
                   cross join min_total m
             where (m.x, m.y) != (i.x, i.y)
          )
        select * from updated_costs
      ) as t
  ),
  part2 as (
    select min(total)
      from costs
     where x = (select max(x) from tiled)
       and y = (select max(y) from tiled)
  )
select * from part2;
