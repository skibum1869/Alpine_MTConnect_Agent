# MTConnnect_Alpine_Docker_Agent Project

This repo houses a Docker-Compose version of the MTConnect Cpp agent. This creates most of the needed items to build a local docker CPP agent using docker and docker-compose.
This project will mirror the log file to the local machine for full trace logging of the agent. This project was origionally forked from [RaymondCui21/MTConnect_Docker](https://github.com/RaymondCui21/MTConnect_Docker), The project has been seperated from the origional code set due to the amount of changes occuring. Then this project was origionally a branch of the debian based release [skibum1869/MTConnect_Docker](https://github.com/skibum1869/MTConnect_Docker) which was fully forked to generate a full release code set. 

# Build from source

To run the project clone a local instance of the repo.

``` bash
git clone https://github.com/skibum1869/MTConnect_Docker.git <name you want for the local repo>
```
Edit the agent.cfg to meet your requirements and add any devices you need to the folder. This has been tested using subfolders for devises and Assets.
To add asset definitions to the compiled project include the following line under the devises line see below.

```bash
# ---- Release ----
### Create folders, copy device files and dependencies for the release
FROM alpine-base AS alpine-release
LABEL author="skibum1869@HEM-Inc" description="Docker image for the latest MTConnect C++ Agent supplied \
from the MTConnect Institute"
EXPOSE 5000:5000/tcp

RUN apk add --no-cache \
  libstdc++ \
  libc6-compat

WORKDIR /MTC_Agent/
# COPY <src> <dest>
COPY docker-entrypoint.sh /MTC_Agent/
COPY agent.cfg /MTC_Agent/
COPY ./Devices/ /MTC_Agent/
COPY agent /MTC_Agent/
COPY --from=alpine-core app_build/schemas/ /MTC_Agent/schemas
COPY --from=alpine-core app_build/simulator/ /MTC_Agent/simulator
COPY --from=alpine-core app_build/styles/ /MTC_Agent/styles
# COPY --from=alpine-core app_build/agent/agent /MTC_Agent/agent
RUN chmod +x /MTC_Agent/agent && \
  chmod +x /MTC_Agent/docker-entrypoint.sh

ENTRYPOINT ["/bin/sh", "-x", "/MTC_Agent/docker-entrypoint.sh"]
### EOF
```

To edit the instance settings use the docker-compose.yml file. 
```yml
version: '3.4'
services:
  web:
    build: .
    environment:
      - TZ=Etc/UTC
    ports: 
      - target: 5000
        published: 5000
        protocol: tcp
        mode: host
    entrypoint: "/bin/sh -x docker-entrypoint.sh"
    working_dir: "/MTC_Agent/"
    container_name: MTConnect_Agent
    restart: unless-stopped
    volumes:
      - type: bind
        source: ./log/adapter.log
        target: /MTC_Agent/adapter.log
        consistency: delegated
```

# Core Docker and MTConnect Commands

## Build comand for docker to create a run time for latest MTC_Agent
```bash
docker build . -t "mtc_agent:latest"
```

## Run the docker image
```bash
docker run --name agent --rm -it mtc_agent
```

## Clear all images and containers
```bash
docker system prune -a
```

## Git pull latest and ignore local changes
``` bash
git reset --hard | sudo git pull
```

## To run the docker-compose file:
``` bash
docker-compose up --force-recreate --build --remove-orphans -d
```

## To shutdown the docker-compose instance
``` bash
docker-compose down
```

## Access the log files
From the pwd type the following:
```bash
grep (what are you searching for) log/adapter.log
```

## Pushing Assets
To push the asset you need to be in the source folder of the asset.
```bash
curl -d @ZWEQ063C34HPII.xml 'http://example.com:5000/asset/ZWEQ063C34HPII.1?device=CTS2_device&type=CuttingTool'
```

Note: depending on the setup of your computer you may have to run the sudo command on a linux machine to get docker-compose to build or destroy a process. 