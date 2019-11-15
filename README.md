# aoc-docker

Run Age of Empires II (WK) headlessly in docker.

## Build

`docker build -t siegeengineers/aoc-headless:1.0 .`

## Run

Prerequisites:
- Set up a directory to drop recorded games (`$(pwd)/dropbox` in the example).
- Have a copy of Age of Empires II available on the docker host.

```
docker run \
  --name aoc \
  --mount type=bind,source="$(pwd)/dropbox",target=/dropbox \
  --mount type=bind,source="$(pwd)/Age of Empires II",target=/aoc \
  siegeengineers/aoc-headless:1.0
```

# Play

Place a recorded game file in the dropbox directory. The log should look something like this:

```
[11/15/19 22:50:37] aoc version 5.8.1
[11/15/19 22:50:37] waiting for files ...
[11/15/19 22:50:43] test.mgz received
[11/15/19 22:50:44] test.mgz playback started
```