[![](https://travis-ci.org/onjin/docker-alpine-postgres.svg)](https://travis-ci.org/onjin/docker-alpine-postgres) [![Docker Stars](https://img.shields.io/docker/stars/onjin/alpine-postgres.svg)](https://registry.hub.docker.com/u/onjin/alpine-postgres/) [![Docker Pulls](https://img.shields.io/docker/pulls/onjin/alpine-postgres.svg)](https://registry.hub.docker.com/u/onjin/alpine-postgres/)

# NOTE: The official PostgreSQL docker image already introduced Alpine based images
- https://hub.docker.com/_/postgres/

# Minimal PostgreSQL images based on Alpine Linux

- https://hub.docker.com/r/onjin/alpine-postgres/


# Supported tags

This repository uses `build-arg` to build required postgresql version with single `Dockerfile`
- `13.0` - [![](https://images.microbadger.com/badges/image/onjin/alpine-postgres:13.0.svg)](https://microbadger.com/images/onjin/alpine-postgres:13.0 "Get your own image badge on microbadger.com")
- `12.4` - [![](https://images.microbadger.com/badges/image/onjin/alpine-postgres:12.4.svg)](https://microbadger.com/images/onjin/alpine-postgres:12.4 "Get your own image badge on microbadger.com")
- `11.9` - [![](https://images.microbadger.com/badges/image/onjin/alpine-postgres:11.9.svg)](https://microbadger.com/images/onjin/alpine-postgres:11.9 "Get your own image badge on microbadger.com")
- `10.14` - [![](https://images.microbadger.com/badges/image/onjin/alpine-postgres:10.14.svg)](https://microbadger.com/images/onjin/alpine-postgres:10.14 "Get your own image badge on microbadger.com")
- `9.6.19` - [![](https://images.microbadger.com/badges/image/onjin/alpine-postgres:9.6.19.svg)](https://microbadger.com/images/onjin/alpine-postgres:9.6.19 "Get your own image badge on microbadger.com")
- `9.5.23` - [![](https://images.microbadger.com/badges/image/onjin/alpine-postgres:9.5.23.svg)](https://microbadger.com/images/onjin/alpine-postgres:9.5.23 "Get your own image badge on microbadger.com")
- `9.4.26` - [![](https://images.microbadger.com/badges/image/onjin/alpine-postgres:9.4.26.svg)](https://microbadger.com/images/onjin/alpine-postgres:9.4.26 "Get your own image badge on microbadger.com")
- `9.3.25` - [![](https://images.microbadger.com/badges/image/onjin/alpine-postgres:9.3.25.svg)](https://microbadger.com/images/onjin/alpine-postgres:9.3.25 "Get your own image badge on microbadger.com")
- `9.2.24` - [![](https://images.microbadger.com/badges/image/onjin/alpine-postgres:9.2.24.svg)](https://microbadger.com/images/onjin/alpine-postgres:9.2.24 "Get your own image badge on microbadger.com")
- `9.1.24` - [![](https://images.microbadger.com/badges/image/onjin/alpine-postgres:9.1.24.svg)](https://microbadger.com/images/onjin/alpine-postgres:9.1.24 "Get your own image badge on microbadger.com")




# What is PostgreSQL?

PostgreSQL, often simply "Postgres", is an object-relational database management system (ORDBMS) with an emphasis on extensibility and standards-compliance. As a database server, its primary function is to store data, securely and supporting best practices, and retrieve it later, as requested by other software applications, be it those on the same computer or those running on another computer across a network (including the Internet). It can handle workloads ranging from small single-machine applications to large Internet-facing applications with many concurrent users. Recent versions also provide replication of the database itself for security and scalability.

PostgreSQL implements the majority of the SQL:2011 standard, is ACID-compliant and transactional (including most DDL statements) avoiding locking issues using multiversion concurrency control (MVCC), provides immunity to dirty reads and full serializability; handles complex SQL queries using many indexing methods that are not available in other databases; has updateable views and materialized views, triggers, foreign keys; supports functions and stored procedures, and other expandability, and has a large number of extensions written by third parties. In addition to the possibility of working with the major proprietary and open source databases, PostgreSQL supports migration from them, by its extensive standard SQL support and available migration tools. And if proprietary extensions had been used, by its extensibility that can emulate many through some built-in and third-party open source compatibility extensions, such as for Oracle.

> [wikipedia.org/wiki/PostgreSQL](https://en.wikipedia.org/wiki/PostgreSQL)

# How to use this image

## start a postgres instance

```console
$ docker run --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -d onjin/alpine-postgres
```

This image includes `EXPOSE 5432` (the postgres port), so standard container linking will make it automatically available to the linked containers. The default `postgres` user and database are created in the entrypoint with `initdb`.

> The postgres database is a default database meant for use by users, utilities and third party applications.  
> [postgresql.org/docs](http://www.postgresql.org/docs/9.3/interactive/app-initdb.html)

## connect to it from an application

```console
$ docker run --name some-app --link some-postgres:postgres -d application-that-uses-postgres
```

## ... or via `psql`

```console
$ docker run -it --link some-postgres:postgres --rm onjin/alpine-postgres sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
```

## Environment Variables

The PostgreSQL image uses several environment variables which are easy to miss. While none of the variables are required, they may significantly aid you in using the image.

### `POSTGRES_PASSWORD`

This environment variable is recommended for you to use the PostgreSQL image. This environment variable sets the superuser password for PostgreSQL. The default superuser is defined by the `POSTGRES_USER` environment variable. In the above example, it is being set to "mysecretpassword".

### `POSTGRES_USER`

This optional environment variable is used in conjunction with `POSTGRES_PASSWORD` to set a user and its password. This variable will create the specified user with superuser power and a database with the same name. If it is not specified, then the default user of `postgres` will be used.

### `PGDATA`

This optional environment variable can be used to define another location - like a subdirectory - for the database files. The default is `/var/lib/postgresql/data`, but if the data volume you're using is a fs mountpoint (like with GCE persistent disks), Postgres `initdb` recommends a subdirectory (for example `/var/lib/postgresql/data/pgdata` ) be created to contain the data.

### `POSTGRES_DB`

This optional environment variable can be used to define a different name for the default database that is created when the image is first started. If it is not specified, then the value of `POSTGRES_USER` will be used.

### `LANG`

This optional environment variable can be used to define a different locale for created cluster. The default is `en_US.UTF-8`.

# How to extend this image

If you would like to do additional initialization in an image derived from this one, add one or more `*.sql` or `*.sh` scripts under `/docker-entrypoint-initdb.d` (creating the directory if necessary). After the entrypoint calls `initdb` to create the default `postgres` user and database, it will run any `*.sql` files and source any `*.sh` scripts found in that directory to do further initialization before starting the service.

These initialization files will be executed in sorted name order as defined by the current locale, which defaults to `en_US.utf8`. Any `*.sql` files will be executed by `POSTGRES_USER`, which defaults to the `postgres` superuser. It is recommended that any `psql` commands that are run inside of a `*.sh` script be executed as `POSTGRES_USER` by using the `--username "$POSTGRES_USER"` flag. This user will be able to connect without a password due to the presence of `trust` authentication for Unix socket connections made inside the container.

# Caveats

If there is no database when `postgres` starts in a container, then `postgres` will create the default database for you. While this is the expected behavior of `postgres`, this means that it will not accept incoming connections during that time. This may cause issues when using automation tools, such as `fig`, that start several containers simultaneously.

Because curren `musl` library version (1.1.16) does not support `LC_COLLATE`, so despite settings `LANG` variable, sorting data will be bytewise (`C`).

# Supported Docker versions

This image is officially supported on Docker version 1.10.1.

Support for older versions (down to 1.6) is provided on a best-effort basis.

Please see [the Docker installation documentation](https://docs.docker.com/installation/) for details on how to upgrade your Docker daemon.

## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans on the [mailing list](http://www.postgresql.org/community/lists/subscribe/) or through a [GitHub issue](https://github.com/onjin/docker-alpine-postgres/issues), especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.

## Testing dockerfiles

In order to build localy all versions and test whether postgres is installed properly
run `./test_build.sh` script.
