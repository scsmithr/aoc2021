drop table if exists input;
create table input (
  line serial primary key,
  num bit(12) not null
);

copy input (num) from '/aoc/03/input';

-- part 1
with bits as (
  select line, num, bits.bit, bits.ord
    from input
         left join lateral unnest(string_to_array(num::text, null)) with ordinality as bits(bit, ord) on true),
  bit_counts as (
    select bit, ord, count(*) as bit_count
      from bits
     group by bit, ord),
  gamma as (
    select string_agg(bit, '' order by ord) as gamma
      from bit_counts
     where bit_count > 500),
  epsilon as (
    select string_agg(bit, '' order by ord) as epsilon
      from bit_counts
     where bit_count < 500)
select gamma::bit(12)::integer * epsilon::bit(12)::integer from gamma, epsilon;

-- whatever
drop table if exists input_oxygen;
create table input_oxygen as table input;

create or replace procedure delete_not_oxygen(bit_ord integer)
  language plpgsql
as $$
  declare
    tbl_count int;
  begin
    select count(*) into tbl_count from input_oxygen;
    with
      bits as (
        select line, num, bits.bit, bits.ord
          from input_oxygen
               left join lateral unnest(string_to_array(num::text, null)) with ordinality as bits(bit, ord) on true),
      bit_counts as (
        select bit, ord, count(*) as bit_count
          from bits
         group by bit, ord),
      to_delete as (
        select line from bits b left join bit_counts bc on b.bit = bc.bit and b.ord = bc.ord
         where b.ord = bit_ord and (bc.bit_count < tbl_count/2 or (bc.bit_count = tbl_count/2 and b.bit = '0'))
      )
        delete from input_oxygen
        where line in (select line from to_delete) and tbl_count != 1;
  end; $$

call delete_not_oxygen(1);
call delete_not_oxygen(2);
call delete_not_oxygen(3);
call delete_not_oxygen(4);
call delete_not_oxygen(5);
call delete_not_oxygen(6);
call delete_not_oxygen(7);
call delete_not_oxygen(8);
call delete_not_oxygen(9);
call delete_not_oxygen(10);
call delete_not_oxygen(11);
call delete_not_oxygen(12);

-- idc
drop table if exists input_co2;
create table input_co2 as table input;

create or replace procedure delete_not_co2(bit_ord integer)
  language plpgsql
as $$
  declare
    tbl_count int;
  begin
    select count(*) into tbl_count from input_co2;
    with
      bits as (
        select line, num, bits.bit, bits.ord
          from input_co2
               left join lateral unnest(string_to_array(num::text, null)) with ordinality as bits(bit, ord) on true),
      bit_counts as (
        select bit, ord, count(*) as bit_count
          from bits
         group by bit, ord),
      to_delete as (
        select line from bits b left join bit_counts bc on b.bit = bc.bit and b.ord = bc.ord
         where bc.ord = bit_ord and (bc.bit_count > tbl_count/2 or (bc.bit_count = tbl_count/2 and b.bit = '1'))
      )
        delete from input_co2
        where line in (select line from to_delete) and tbl_count != 1;
  end; $$

call delete_not_co2(1);
call delete_not_co2(2);
call delete_not_co2(3);
call delete_not_co2(4);
call delete_not_co2(5);
call delete_not_co2(6);
call delete_not_co2(7);
call delete_not_co2(8);
call delete_not_co2(9);
call delete_not_co2(10);
call delete_not_co2(11);
call delete_not_co2(12);

-- part 2
select input_co2.num::integer * input_oxygen.num::integer from input_co2, input_oxygen;

-- some stuff
-- with recursive
--   bits as (
--     select line, num, bits.bit, bits.ord
--       from input
--            left join lateral unnest(string_to_array(num::text, null)) with ordinality as bits(bit, ord) on true),
--   bit_counts as (
--     select bit, ord, count(*) as bit_count
--       from bits
--      group by bit, ord),
--   mc_bits(num, ord, bit_count, curr_bit, curr_count) as (
--     select b.num, b.ord+1, bc.bit_count, b.bit, count(*)
--       from bits b left join bit_counts bc on b.ord = bc.ord and b.bit = bc.bit
--      group by b.num, b.ord, b.bit, bc.bit_count
--      union all
--     select num, ord+1, bit_count, curr_bit, curr_count
--       from mc_bits
--      where bit_count > (curr_count / 2) or (bit_count = (curr_count / 2) and curr_bit = '1'))
-- select * from mc_bits;
-- select oxygen_gen_rating::integer * co2_scrub_rating::integer from oxygen_gen_rating, co2_scrub_rating;


-- most_common_bit_mismatches as (
--   select b.line, min(b.ord) as first_mismatch
--     from bits as b left join bit_counts as bc on b.ord = bc.ord and bc.bit = b.bit
--    where bc.bit_count < 500
--       or (bc.bit_count = 500 and b.bit = '0')
--    group by b.line),
-- mc_joined as (
--   select bits.line, bits.num, coalesce(mc.first_mismatch, 13) as first_mismatch
--     from bits left join most_common_bit_mismatches mc on bits.line = mc.line),
-- oxygen_gen_rating as (
--   select num as oxygen_gen_rating
--     from mc_joined
--    order by first_mismatch desc
--    limit 1),
-- least_common_bit_mismatches as (
--   select b.line, min(b.ord) as first_mismatch
--     from bits as b left join bit_counts as bc on b.ord = bc.ord and bc.bit = b.bit
--    where bc.bit_count > 500
--       or (bc.bit_count = 500 and b.bit = '1')
--    group by b.line),
-- lc_joined as (
--   select bits.line, bits.num, coalesce(lc.first_mismatch, 13) as first_mismatch
--     from bits left join least_common_bit_mismatches lc on bits.line = lc.line),
-- co2_scrub_rating as (
--   select num as co2_scrub_rating
--     from lc_joined
--    order by first_mismatch desc
--    limit 1)
