# Docker image for Datomic Free

An unofficial Docker image packaging the [Datomic Free][datomic-free-download]
transactor.

## Quickstart

In one terminal, run the transactor:

```sh
docker run -it --rm \
  -p 127.0.0.1:4334-4336:4334-4336 \
  gordonstratton/datomic-free-transactor:latest
```

Wherever you use `datomic.api/connect`, you can now connect to your running
transactor:

```clojure
(require '[datomic.api :as d])

(def conn
  (d/connect "datomic:free://localhost:4334/my-database"))

;; Or, if you have the Datomic Pro client library, you can use the `dev`
;; protocol:
;(def conn
;  (d/connect "datomic:dev://localhost:4334/my-database"))
```

## Features

- **Automatic memory sizing**: Pass `--memory` to `docker run` to get 4G, 2G,
  1G, and 512M versions of the transactor automatically, depending on how much
  memory is available to the container!
- **Secure by default**: Runs as a non-root `datomic` user by default.
- **Logs to standard output**: Follows Docker best practices and logs to
  standard output. No log files to manage, and no extra log files lying around
  in the container!

## Configuration

### Using volumes

In order to have your data persist across container instances, you may want to
use Docker volumes or host paths. You need to mount your volumes at
`/srv/datomic/data` inside the container, like this example:

```
docker run -it --rm \
  -p 127.0.0.1:4334-4336:4334-4336 \
  -v /path/to/your/host/data:/srv/datomic/data \
  gordonstratton/datomic-free-transactor:latest
```

The `datomic` user and group from inside the container must be able to read from
and write to this location. **Note:** the entrypoint will attempt to take care
of this automatically, unless `DATOMIC_NO_CHOWN_DATA` is set (non-empty).

### Reference

The following environment variables control other aspects of the container:

| Variable | Description | Default |
| --- | --- | --- |
| `DATOMIC_HOST` | The host Datomic binds to _inside_ the container. You will probably never change this, but advanced users might need to. | `0.0.0.0` |
| `DATOMIC_ALT_HOST` | This must match the hostname you use to access the containerized transactor. This is typically set when run with Docker Compose. | `localhost` |
| `DATOMIC_STORAGE_ADMIN_PASSWORD` | https://docs.datomic.com/on-prem/configuring-embedded.html | `admin` |
| `DATOMIC_OLD_STORAGE_ADMIN_PASSWORD` | https://docs.datomic.com/on-prem/configuring-embedded.html | |
| `DATOMIC_STORAGE_DATOMIC_PASSWORD` | https://docs.datomic.com/on-prem/configuring-embedded.html | `datomic` |
| `DATOMIC_OLD_STORAGE_DATOMIC_PASSWORD` | https://docs.datomic.com/on-prem/configuring-embedded.html | |
| `DATOMIC_NO_CHOWN_DATA` | If non-empty, this prevents the entrypoint from changing the ownership of the data directory | |

## Development

Update the `Dockerfile`.

Create a new image with:

```sh
make image
```

Test the image to your satisfaction. Then, push the image upstream:

```sh
make push
```

[datomic-free-download]: https://my.datomic.com/downloads/free
