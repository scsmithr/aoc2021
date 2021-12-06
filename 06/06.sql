drop table if exists input;
create table input (
  line serial primary key,
  value text not null
);

copy input (value) from '/aoc/06/input';

drop table if exists fish;
select string_to_table(value, ',')::integer as timer
  into fish
  from input;

select 0 as day,
       count(*) filter (where timer = 0) as t0,
       count(*) filter (where timer = 1) as t1,
       count(*) filter (where timer = 2) as t2,
       count(*) filter (where timer = 3) as t3,
       count(*) filter (where timer = 4) as t4,
       count(*) filter (where timer = 5) as t5,
       count(*) filter (where timer = 6) as t6,
       count(*) filter (where timer = 7) as t7,
       count(*) filter (where timer = 8) as t8
  into fish_temp
  from fish;

select day+1 as day,
       t1 as t0,
       t2 as t1,
       t3 as t2,
       t4 as t3,
       t5 as t4,
       t6 as t5
  from fish_temp;


with recursive
  tick (day, t0, t1,t2,t3,t4,t5,t6,t7,t8) as(
    select 0 as day,
           count(*) filter (where timer = 0) as t0,
           count(*) filter (where timer = 1) as t1,
           count(*) filter (where timer = 2) as t2,
           count(*) filter (where timer = 3) as t3,
           count(*) filter (where timer = 4) as t4,
           count(*) filter (where timer = 5) as t5,
           count(*) filter (where timer = 6) as t6,
           count(*) filter (where timer = 7) as t7,
           count(*) filter (where timer = 8) as t8
      from fish
     union all
    select day+1 as day,
           t1 as t0,
           t2 as t1,
           t3 as t2,
           t4 as t3,
           t5 as t4,
           t6 as t5,
           t7 + t0 as t6, -- include fish that gave birth
           t8 as t7,
           t0 as t8 -- new fish born
      from tick
     where day < 256
  )
select day, t0+t1+t2+t3+t4+t5+t6+t7+t8
  from tick
 where day = 80 or day = 256;
