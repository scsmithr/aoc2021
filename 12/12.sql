drop table if exists input;
create table input (
  line serial primary key,
  value text not null
);

copy input (value) from '/aoc/12/input';

-- part 1
with recursive
  connections as (
    select a[1] as cave,
           a[2] as dest
      from input cross join string_to_array(value, '-') a
  ),
  all_conns (cave, dest) as (
    select cave, dest from connections
     union all
    select dest, cave from connections
  ),
  paths (cave, dest, path) as (
    select cave,
           dest,
           array[cave] as path
      from all_conns
     where cave = 'start'
     union all
    select c.cave,
           c.dest,
           p.path || c.cave
      from paths p
           inner join all_conns c on p.dest = c.cave
     where not (lower(c.cave) = c.cave and c.cave = any(p.path))
       and c.cave != 'end'
  ),
  complete_paths as (
    select distinct path
      from paths
     where dest = 'end'
  ),
  part1 as (
    select count(*) from complete_paths
  )
select * from part1;

-- part 2
with recursive
  connections as (
    select a[1] as cave,
           a[2] as dest
      from input cross join string_to_array(value, '-') a
  ),
  all_conns (cave, dest) as (
    select cave, dest from connections
     union all
    select dest, cave from connections
  ),
  paths (cave, dest, path, visited_twice) as (
    select cave,
           dest,
           array[cave] as path,
           false       as visited_twice
      from all_conns
     where cave = 'start'
     union all
    select c.cave,
           c.dest,
           p.path || c.cave,
           (case
            when p.visited_twice then p.visited_twice
            else (lower(c.cave) = c.cave and c.cave = any(p.path))
            end) as visited_twice
      from paths p
           inner join all_conns c on p.dest = c.cave
     where not (p.visited_twice and (lower(c.cave) = c.cave and c.cave = any(p.path)))
       and c.cave != 'end'
       and c.cave != 'start'
  ),
  complete_paths as (
    select distinct path
      from paths
     where dest = 'end'
  ),
  part2 as (
    select count(*) from complete_paths
  )
select * from part2;
