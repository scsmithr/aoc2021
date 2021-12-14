drop table if exists input;
create table input (
  line serial primary key,
  value text not null
);

copy input (value) from '/aoc/14/input';

drop table if exists elements;
select ordinality, element
  into elements
  from input cross join unnest(string_to_array(value, null)) with ordinality element
 where line = 1;

drop table if exists rules;
select v[1] as left_el,
       v[2] as right_el,
       v[3] as insert_el
  into rules
  from input cross join regexp_match(value, '^([A-Z])([A-Z]) -> ([A-Z])') v
 where value like '% -> %';

with recursive
  steps (step, left_el, right_el, pair_count) as (
    select 0                                        as step,
           element                                  as left_el,
           lead(element) over (order by ordinality) as right_el,
           1::bigint                                as pair_count
      from elements
     union all
    select nc.step+1,
           nc.left_el,
           nc.right_el,
           nc.pair_count::bigint
      from (
        with
          initial_counts as (
            select step, left_el, right_el, pair_count
              from steps
          ),
          changes as (
            select step,
                   (case s
                    when 1 then r.left_el
                    when 2 then r.insert_el
                    when 3 then c.left_el end)  as left_el,
                   (case s
                    when 1 then r.insert_el
                    when 2 then r.right_el
                    when 3 then c.right_el end) as right_el,
                   (case
                    when s in (1,2) then c.pair_count
                    else -c.pair_count end)     as change
              from initial_counts c
                   inner join rules r on (c.left_el = r.left_el and c.right_el = r.right_el)
                   cross join generate_series(1, 3) s
          ),
          new_counts as (
            select step,
                   c.left_el,
                   c.right_el,
                   sum(c.change) as pair_count
              from (
                select * from changes
                 union all
                select * from initial_counts) as c
             group by step, c.left_el, c.right_el
          )
        select * from new_counts where pair_count > 0
      ) as nc
     where step < 40
  ),
  el_counts as (
    select step, left_el, sum(pair_count) as el_count
      from steps
     group by step, left_el
  )
select step, max(el_count) - min(el_count)
  from el_counts
 where step in (10, 40)
 group by step
