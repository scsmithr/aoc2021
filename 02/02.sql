drop table if exists input;
create table input (
  line serial primary key,
  direction varchar(7) not null,
  amount int not null
);

\timing on
  ;

copy input (direction, amount) from '/aoc/02/input' delimiter ' ';

-- part 1
with
  values as (
    -- Poor man's pivot.
    select sum(amount) filter (where direction = 'forward') as forward,
           sum(amount) filter (where direction = 'up') as up,
           sum(amount) filter (where direction = 'down') as down
      from input)
select forward * (down - up) from values;

-- part 2
with
  aims as (
    select direction,
           amount,
           sum(case
               when direction = 'up' then -amount
               when direction = 'down' then amount
               else 0 end) over (order by line) as aim
      from input)
select sum(amount) * sum(amount * aim)
  from aims
 where direction = 'forward';
