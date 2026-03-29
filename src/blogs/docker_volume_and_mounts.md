# Docker Volumes and Mounts

![docker-new](./assets/assets-docker-volume-blog/docker-new.jpg)

Containers storage is temporary by default. That means:
- File changes inside the container vanish once the container is removed.
- If you want [persistent storage](https://www.geeksforgeeks.org/cloud-computing/what-is-persistent-storage/), you need a way to store data outside the container's lifecycle

Docker gives us two main ways:
1. Volumes - Managed by Docker, stored in Docker's managed storage area.
2. Bind Mounts - You directly link a folder on your host machine.

# Volumes

- Created and managed by Docker.
- Stored under `/var/lib/docker/volumes`(on Linux).
- Best for: databases, or when you want a secured data storage which is managed by docker itself.
- You don't care about setting up the data storage path, Docker manages everything for you.

Example:

Let's say you have a postgresql container, and you want to persist the data even after the container is removed. We can do it using docker volumes.

```bash
# Creating a new volume
docker volume create mypgstore

# Checking the available volumes
docker volume ls
# mypgstore will be present in the list.

# Creating a postgres container and storing the data in mypgstore volume
docker run -d \ 
--name postgres-local \
-v mypgstore:/var/lib/postgresql/data \
-e POSTGRES_PASSWORD=your_password \
-p 5432:5432 \
postgres

```

Here:
- `mypgstore` is created by Docker.
- Anything written in `/var/lib/postgresql/data` inside the container gets stored in the volume `mypgstore`.
- Ever if you delete the container, the volume persists and you can use it in any other container and gets the same data.

### Alternatively there is a long syntax of mounting a volume into a container apart from using `-v`

```bash
docker run -d \
-it --name postgres-local \
--mount type=volume,source=mypgstore,target=/var/lib/postgresql/data \
-e POSTGRES_PASSWORD=your_password \
-p 5432:5432 \
postgres
```

## Access Modes in Docker Volumes
1. `:rw`(read-write) -> Default
- Container can read and write to the mount
- Example:
```bash
docker run -v mydata:/app:rw python

# using mount we need not to define readwrite as it is default
docker run \
--mount type=volume,source=mydata,target=/app \
python
```

2. `:ro`(read-only)
- Container can only read, not modify files.
- Example:
```bash
docker run -v mydata:/app:ro python


# using mount
docker run \
--mount type=volume,source=mydata,target=/app,readonly \
python

```

- Useful when you want to mount config files or source code but prevent the container from changing them.

## Docker Volume Lifecycle
- Containers can be deleted without affecting volumes. But if you delete the volume, data is gone.

Commands to manage a Volume Lifecycle: 
```
docker volume ls       # list
docker volume inspect  # details (location, driver)
docker volume rm       # remove
docker volume prune    # remove unused volumes
```

## Backuping the Docker Volume
The trick is: run a throwaway container, mount the volume, and copy its contents into a tar file.

Example:
```bash
docker run --rm \
-v mydata:/data \
-v $(pwd):/backup \
busybox \
tar czf /backup/mydata_backup.tar.gz -C /data .
```

- `mydata:/data` - mounts your Docker volume into the container.
- `$(pwd):/backup` - mounts your current host directory to save the backup.
- `tar czf` - compresses everything into mydata_backup.tar.gz.

After this, the backup file will be in your host machine’s current folder.

## Restore the backup Volume
```bash
docker run --rm \
-v mydata:/data \
-v $(pwd):/backup \
busybox \
tar xzf /backup/mydata_backup.tar.gz -C /data
```

## Volumes in Docker Compose

Example:

```
version: "3.9"
services:
  db:
    image: postgres:15
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

- Here, pgdata is a named volume created and managed by Compose.
- When you tear down containers (`docker compose down`), the volume stays unless you add `-v`.

# Bind Mounts
- Direct link between a host directory and a container directory
- Useful for development, when you want your host files available inside the container.

Example:

Let's say we have some development going on of somewebpage and we need to serve it using python and track latest changes, We can do this using docker bind mounts

```bash
# lets say we are in a directory name html with an index.html file
# we can bind mount this into the container
docker run --rm -it \
-v $(pwd):/data \
-p 8000:8000 \
--name python-webserver \
python:latest \
/bin/bash

# After running this command we go into the container shell and we can serve out html files using python

# changing the current directory to the bind mount directory data/
cd data/

# run the python http server
python3 -m http.server

# Now when we change our index.html in the host directory, it'll change in the container directory. 
```

Here:
- Your current directory `$(pwd)` on the host is mounted inside `/data` in the container.
- Any change you make on your host immediately shows up in the container, and vice verca.

_Note:_ __Bind Mounts__ are just Hard links to your local directory which is good for dev environment, but riskier in prod. 


### Alternatively there is a long syntax of bind mount apart from using `-v`
```bash
docker run --rm -it \
--mount type=bind,source="$(pwd)",target=/data \
-p 8000:8000 \
--name python-webserver \
python:latest \
/bin/bash
```

## Access Modes in Docker Mounts
1. `:rw`(read-write) -> Default
- Container can read and write to the mount
- Example:
```bash
docker run -v $(pwd):/app:rw python

# using mount we need not to specify readwrite as it is default
docker run \
--mount type=bind,source="$(pwd)",target=/app \
python
```

2. `:ro`(read-only)
- Container can only read, not modify files.
- Example:
```bash
docker run -v $(pwd):/app:ro python


# using mount
docker run \
--mount type=bind,source="$(pwd)",target=/app,readonly \
python

```

- Useful when you want to mount config files or source code but prevent the container from changing them.

## Bind Mounts in Docker Compose

```bash
services:
  web:
    image: node:18
    working_dir: /app
    volumes:
      - .:/app   # bind mount: host project folder => container
    command: npm start

```

# tmpfs Mounts ( special reference )
- Data is stored in host memory only (never on disk).
- Super fast, but disappears when the container stops.

Example:
```bash
docker run -d \
--mount type=tmpfs,target=/app/cache \
nginx
```

- Useful for caching, secrets, or sensitive data you don’t want written to disk.
