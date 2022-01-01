drop table if exists input;
create table input (
  line serial primary key,
  value text not null
);

copy input (value) from '/aoc/20/input';

drop table if exists replacements;
select arr.ord - 1 as idx,
       (case arr.val
        when '#' then '1'
        when '.' then '0'
        end)       as val
  into replacements
  from input
       cross join unnest(string_to_array(value, null)) with ordinality arr(val, ord)
 where line = 1;

drop table if exists pixels;
select (arr.ord - 1)::bigint as x,
       (line - 3)::bigint    as y,
       (case arr.val
        when '#' then '1'
        when '.' then '0'
        end)                 as val
  into pixels
  from input
       cross join unnest(string_to_array(value, null)) with ordinality arr(val, ord)
 where line >= 3;

-- explain
with recursive
  enhancements (step, x, y, val) as (
    select 0, x, y, val
      from pixels
     union all
    select u.step + 1,
           u.x,
           u.y,
           u.val
      from (
        with
          curr_pixels as (select step, x, y, val from enhancements),
          max_coord   as (select max(x) as m from curr_pixels),
          curr_step   as (select max(step) as step from curr_pixels),
          padded_pixels as (
            select coalesce(p.x, p2.x) + 1     as x,
                   coalesce(p.y, p2.y) + 1     as y,
                   coalesce(p.val, p2.def_val) as val
              from curr_pixels p
                   right outer join (
                     select (case
                             when step % 2 = 0 then '0'
                             else flip_val end) as def_val,
                            x,
                            y
                       from generate_series(-2, (select m+2 from max_coord)) x
                            cross join generate_series(-2, (select m+2 from max_coord)) y
                            cross join (select step from curr_step) s(step)
                            cross join (select val from replacements where idx = 0) r(flip_val)
                   ) as p2 on (p.x, p.y) = (p2.x, p2.y)
          ),
          precomputed_coords as (
            select p.x,
                   p.y,
                   p.x + xdiff as nx,
                   p.y + ydiff as ny
              from padded_pixels p
                   cross join lateral generate_series(-1, 1) xdiff
                   cross join lateral generate_series(-1, 1) ydiff
          ),
          convolved_pixels as (
            select p1.x,
                   p1.y,
                   string_agg(p2.val, '' order by p2.y, p2.x)::bit(9)::integer as idx
              from precomputed_coords p1
                   left join padded_pixels p2 on (p1.nx, p1.ny) = (p2.x, p2.y)
                   cross join (select m+3 from max_coord) pmax(m)
             where p1.x not in (-1, pmax.m)
               and p1.y not in (-1, pmax.m)
             group by p1.x, p1.y
          ),
          updated_pixels as (
            select s.step,
                   c.x,
                   c.y,
                   r.val
              from convolved_pixels c
                   left join replacements r on c.idx = r.idx
                   cross join curr_step s
          )
        select * from updated_pixels
      ) as u
     where step < 50
  ),
  part1 as (select count(*) from enhancements where step = 2 and val = '1'),
  part2 as (select count(*) from enhancements where step = 50 and val = '1')
select * from part1, part2;
