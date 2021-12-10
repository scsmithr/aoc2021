drop table if exists input;
create table input (
  line serial primary key,
  value text not null
);

copy input (value) from '/aoc/10/input';

with recursive
  brackets as (
    select line, string_to_array(value, null) as brackets from input
  ),
  stacks (line, idx, brackets, stack, mismatch) as (
    select line,
           1                  as idx,
           brackets,
           array[brackets[1]] as stack,
           null               as mismatch
      from brackets
     union all
    select line,
           idx + 1              as idx,
           brackets,
           (case brackets[idx+1] in ('[', '(', '{', '<')
            when true then brackets[idx+1] || stack
            else stack[2:] end) as stack,
           (case
            when brackets[idx+1] = ']' and stack[1] != '[' then ']'
            when brackets[idx+1] = ')' and stack[1] != '(' then ')'
            when brackets[idx+1] = '}' and stack[1] != '{' then '}'
            when brackets[idx+1] = '>' and stack[1] != '<' then '>'
            else null end
           )                    as mismatch
      from stacks
     where idx < cardinality(brackets) and mismatch is null
  ),
  scores as (
    select case mismatch
           when ')' then 3
           when ']' then 57
           when '}' then 1197
           when '>' then 25137
           end as score
      from stacks
     where mismatch is not null
  ),
  part1 as (select sum(score) from scores),
  last_idxs as (
    select line,
           max(idx) as last_idx
      from stacks
     group by line
  ),
  incomplete_stacks as (
    select s.line,
           s.idx,
           s.brackets,
           s.stack
      from stacks s
           inner join last_idxs l on s.line = l.line and s.idx = l.last_idx
     where s.mismatch is null
  ),
  bracket_scores as (
    select i.line,
           (case bracket
            when '(' then 1
            when '[' then 2
            when '{' then 3
            when '<' then 4
            end)      as score,
           ordinality as idx
      from incomplete_stacks i
           cross join lateral unnest(i.stack) with ordinality bracket
  ),
  agg_scores (line, score, idx) as (
    select line, score::bigint, idx
      from bracket_scores
     where idx = 1
     union all
    select a.line,
           a.score * 5 + b.score,
           b.idx
      from agg_scores a
           inner join bracket_scores b on (a.line = b.line and a.idx + 1 = b.idx)
  ),
  max_scores as (
    select line,
           max(score) max_score
      from agg_scores
     group by line
  ),
  part2 as (
    select percentile_disc(0.5) within group (order by max_score) as middle
      from max_scores
  )
select * from part1, part2;

