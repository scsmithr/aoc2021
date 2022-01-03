drop table if exists input;
create table input (
  line serial primary key,
  value text not null
);

copy input (value) from '/aoc/21/input';

drop table if exists starts;
select v[1]::bigint as player,
       v[2]::bigint as position
  into starts
  from input
       cross join regexp_match(value, '^Player (\d+) starting position: (\d+)') v;

-- part1
with
  rolls as (
    select d.side,
           d.n,
           ((row_number - 1) / 6) + 1 as move_number,
           (case
            when (row_number - 1) % 6 < 3 then 1
            else 2 end) as player
      from (
        select *, row_number() over (order by n, side)
          from generate_series(1, 100) side
               cross join generate_series(1, 100) n
      ) as d
  ),
  moves as (
    select 0 as move_number,
           player,
           position as move_total
      from starts
     union all
    select move_number,
           player,
           (sum(side) - 1) % 10 + 1 as move_total
      from rolls
     group by move_number, player
  ),
  positions as (
    select m.move_number,
           m.player,
           m.move_total,
           (sum(m.move_total) over (partition by m.player order by m.move_number) - 1) % 10 + 1 as board_pos
      from moves m
           left join starts s on m.player = s.player
  ),
  scores as (
    select move_number,
           player,
           board_pos,
           sum(board_pos) over (partition by player order by move_number) as score
      from positions
     where move_number >= 1
  ),
  winning_move_number as (
    select move_number - 1 as move_number,
           player,
           score
      from scores
     where score >= 1000
     order by move_number, player
     limit 1
  ),
  opponents_score as (
    select s.player,
           s.score,
           w.move_number
      from winning_move_number w
           inner join scores s on w.move_number = s.move_number
     where s.player != w.player
  ),
  num_rolls as (
    select (case
            when player = 1 then move_number * 6 + 3
            else (move_number + 1) * 6 end) as num_rolls
      from winning_move_number
  ),
  part1 as (
    select n.num_rolls * s.score
      from opponents_score s
           cross join num_rolls n
  )
select * from part1;
