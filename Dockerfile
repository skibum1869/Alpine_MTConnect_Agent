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
    useradd -G app -D -s /sbin/nologin app

# Set the home directory to our app user's home.
ENV HOME=/home/app
ENV APP_HOME=/home/app/MTC_Agent

# Chown all the files to the app user.
RUN chown -R app:app $APP_HOME

RUN	apk add --no-cache \
	libstdc++ \
	libc6-compat

WORKDIR $APP_HOME
# COPY <src> <dest>
COPY agent.cfg docker-entrypoint.sh $APP_HOME
COPY ./Devices/ $APP_HOME
COPY ./Assets/ $APP_HOME/assets
COPY --from=alpine-core app_build/schemas/ $APP_HOME/schemas
COPY --from=alpine-core app_build/simulator/ $APP_HOME/simulator
COPY --from=alpine-core app_build/styles/ $APP_HOME/styles
COPY --from=alpine-core app_build/agent/agent $APP_HOME/

# Set permission on the folder
RUN RUN chown -R app:app $APP_HOME &&\
	chmod +x $APP_HOME/agent && \
	chmod +x $APP_HOME/docker-entrypoint.sh

# Change to the app user.
USER app

ENTRYPOINT ["/bin/sh", "-x", "/home/app/MTC_Agent/docker-entrypoint.sh"]
### EOF
