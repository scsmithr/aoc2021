drop table if exists input;
create table input (
  line serial primary key,
  value text not null
);

copy input (value) from '/aoc/08/input';

drop table if exists entries;
select line, strings[0:10] || strings[12:15] as segments
  into entries
  from input cross join lateral string_to_array(value, ' ') strings;

with
  segments as (
    select line,
           ordinality,
           string_to_array(segment, null) as segment
      from entries cross join lateral unnest(segments) with ordinality as segment
  ),
  knowns as (
    select line,
           ordinality,
           segment,
           (case
            when array_length(segment, 1) = 2 then 1
            when array_length(segment, 1) = 4 then 4
            when array_length(segment, 1) = 3 then 7
            when array_length(segment, 1) = 7 then 8
            else null end) as known
      from segments
  ),
  combos as (
    select s.line,
           s.ordinality,
           s.segment,
           k.segment as known_segment,
           k.known,
           array_length(s.segment, 1) as seg_len,
           array_length(k.segment, 1) as known_len,
           array_length(array(select unnest(s.segment) intersect select unnest(k.segment)), 1) as num_intersect
      from segments s inner join knowns k on s.line = k.line
  ),
  candidates as (
    select line,
           ordinality,
           segment,
           (case
            when seg_len = known_len and num_intersect = seg_len then known
            when seg_len = 5 and known = 7 and num_intersect = 3 then 3
            when seg_len = 5 and known = 4 and num_intersect = 3 then 5
            when seg_len = 5 then 2
            when seg_len = 6 and known = 4 and num_intersect = 4 then 9
            when seg_len = 6 and known = 7 and num_intersect = 3 then 0
            when seg_len = 6 then 6
            else null end
           ) as num
      from combos
  ),
  numbers as (
    select distinct
      line,
      ordinality,
      first_value(num) over (partition by line, ordinality order by array_position(array[1,4,7,8,3,5,2,9,0,6], num)) as num
      from candidates
     where num is not null
  ),
  part1 as (select count(*) from numbers where num in (1, 4, 7, 8) and ordinality > 10),
  output_numbers as (
    select string_agg(num::text, '' order by ordinality)::integer as output
      from numbers
     where ordinality > 10
     group by line
  ),
  part2 as (select sum(output) from output_numbers)
select * from part1, part2;
