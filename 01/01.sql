drop table if exists input;
create table input (
  line serial primary key,
  depth int not null
);

copy input (depth) from '/aoc/01/input';

-- part 1
select count(*) from (
  select depth > lag(depth, 1) over (order by line) as comparison
    from input
) as comparisons where comparison = true;

-- part 2
with window_sums as (
  select
    row_number() over (order by line) as line,
    depth
      + lag(depth, 1) over (order by line)
      + lag(depth, 2) over (order by line) as window_sum
    from input)
select count(*) from (
  select window_sum > lag(window_sum, 1) over (order by line) as comparison
    from window_sums
) as comparisons where comparison = true;
