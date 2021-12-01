My solutions for Advent of Code 2021 using Postgres.

Start postgres container:
```shell
docker run --rm --name postgres-aoc -e POSTGRES_HOST_AUTH_METHOD=trust -v $PWD:/aoc -d postgres:14
```

User is `postgres` with no password. Database is `postgres`.

Get container ip address:
```shell
docker inspect postgres-aoc | jq .[0].NetworkSettings.IPAddress
```

Download input for day:
```shell
curl -H @session "https://adventofcode.com/2021/day/<day>/input" -o <day>/input
```
