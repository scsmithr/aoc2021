drop table if exists input;
create table input (
  line serial primary key,
  value text not null
);

copy input (value) from '/aoc/04/input';

-- Move draws to its own table.
drop table if exists draws;
select ordinality as num,
       array_agg(unnest) over (order by ordinality) as draws
  into draws
  from input cross join lateral unnest(string_to_array(value, ',')) with ordinality
 where line = 1;

-- Remove draws from input table, and remove all empty lines.
delete from input
 where line = 1 or value = '';

select line/5 as board, numbers as board_row
  from (
    select line, regexp_split_to_array(btrim(string_agg(value, ' ')), '\s+') as numbers
      from (select row_number() over (order by line) - 1 as line, value
              from input) as _
     group by line
     order by line) as _ limit 10;

-- Move boards to their own table.
drop table if exists boards;
with
  -- Get each board row.
  board_rows as (
    select line/5 as board, numbers as board_row
      from (
        select line, regexp_split_to_array(btrim(string_agg(value, ' ')), '\s+') as numbers
          from (select row_number() over (order by line) - 1 as line, value
                  from input) as _
         group by line
         order by line) as _),
  -- Unordered column values.
  board_cols as (
    select line/5 as board,
           regexp_split_to_array(btrim(string_agg(value, ' ')), '\s+') as board_col
      from (
        select row_number() over (partition by line) as col, *
          from (
            select row_number() over (order by line) - 1 as line,
                   unnest(regexp_split_to_array(btrim(value), '\s+')) as value
              from input) as _) as _
     group by col, line/5
     order by line/5),
  -- Get all values on the board.
  board_vals as (
    select r.board, array_agg(values) as values
      from board_rows r cross join lateral unnest(r.board_row) values
     group by board),
  winners as (
    select board, board_col as winner from board_cols
     union
    select board, board_row as winner from board_rows)
select v.board,
       v.values,
       w.winner
  into boards
  from board_vals v left join winners w on v.board = w.board;

-- part 1
with
  winners as (
    select b.board,
           b.values,
           first_value(d.draws) over (partition by b.board order by cardinality(d.draws)) as draws,
           d.draws[cardinality(d.draws)] as last_draw
      from boards b left join draws d on d.draws @> b.winner),
  winner as (
    select board, values, draws, last_draw
      from winners
     order by cardinality(draws)
     limit 1
  ),
  unmarked_sum as (
    select sum(cast(v as integer))
      from winner cross join lateral unnest(winner.values) v
           left join unnest(winner.draws) d on v = d
     where d is null
  )
select u.sum * cast(w.last_draw as integer) from unmarked_sum u, winner w;

-- part 2
with
  winners as (
    select b.board,
           b.values,
           first_value(d.draws) over (partition by b.board order by cardinality(d.draws)) as draws,
           d.draws[cardinality(d.draws)] as last_draw
      from boards b left join draws d on d.draws @> b.winner),
  winner as (
    select board, values, draws, last_draw
      from winners
     order by cardinality(draws) desc
     limit 1
  ),
  unmarked_sum as (
    select sum(cast(v as integer))
      from winner cross join lateral unnest(winner.values) v
           left join unnest(winner.draws) d on v = d
     where d is null
  )
select u.sum * cast(w.last_draw as integer) from unmarked_sum u, winner w;
