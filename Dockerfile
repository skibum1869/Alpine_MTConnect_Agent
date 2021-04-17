#!/bin/sh
### Alpine Version

# ---- alpine base instance ----
FROM alpine:latest AS alpine-base

# ---- alpine core ----
# Get and install glibc for alpine
FROM alpine-base AS alpine-core

## Testing to see if the code above is not needed 
RUN apk upgrade \
	&& apk add git \
	python3 \
	cmake \
	g++ \
	make

# Install and run cmake and make components
RUN git clone --recurse-submodules --progress https://github.com/mtconnect/cppagent.git --depth 1 /app_build/ \
	&& cd /app_build/ \
	&& git submodule init \
	&& git submodule update \
	&& cmake -G 'Unix Makefiles' --config Release . \
	&& make

# ---- Release ----
### Create folders, copy device files and dependencies for the release
FROM alpine-base AS alpine-release
LABEL author="skibum1869" description="Alpine based docker image for the latest Release Version of the MTConnect C++ Agent"
EXPOSE 5000:5000/tcp

# Create an app user so our program doesn't run as root.
RUN addgroup app &&\
    adduser -G app -D -s /sbin/nologin app

RUN	apk add --no-cache \
	libstdc++ \
	libc6-compat

WORKDIR /home/app/MTC_Agent
# COPY <src> <dest>
COPY agent.cfg docker-entrypoint.sh /home/app/MTC_Agent/
COPY ./Devices/ /home/app/MTC_Agent
COPY ./Assets/ /home/app/MTC_Agent/assets
COPY --from=alpine-core app_build/schemas/ /home/app/MTC_Agent/schemas
COPY --from=alpine-core app_build/simulator/ /home/app/MTC_Agent/simulator
COPY --from=alpine-core app_build/styles/ /home/app/MTC_Agent/styles
COPY --from=alpine-core app_build/agent/agent /home/app/MTC_Agent/

# Set permission on the folder
RUN chown -R app:app /home/app/MTC_Agent &&\
	chmod +x /home/app/MTC_Agent/agent && \
	chmod +x /home/app/MTC_Agent/docker-entrypoint.sh

# Change to the app user.
USER app

ENTRYPOINT ["/bin/sh", "-x", "./docker-entrypoint.sh"]
### EOF
