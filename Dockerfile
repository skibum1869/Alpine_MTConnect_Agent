#!/bin/sh
### Alpine Version
# ---- alpine glibc instance ----
### alpine glibc instance
FROM alpine:latest AS alpine-base

# ---- alpine make ----
### alpine glibc instance

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
RUN git clone --recurse-submodules --progress https://github.com/mtconnect/cppagent.git /app_build/ \
	&& cd /app_build/ \
	&& git submodule init \
	&& git submodule update \
	&& cmake -G 'Unix Makefiles' --config Release . #\
	# && make ## Commented out untill the DLib.cmake file is corrected for the 64 bit binaries on the cppagent repo from MTConnect Instute

# ---- Release ----
### Create folders, copy device files and dependencies for the release
FROM alpine-base AS alpine-release
LABEL author="skibum1869" description="Alpine based docker image for the latest Release Version of the MTConnect C++ Agent"
EXPOSE 5000:5000/tcp

RUN	apk add --no-cache \
	libstdc++ \
	libc6-compat

WORKDIR /MTC_Agent/
# COPY <src> <dest>
COPY agent agent.cfg docker-entrypoint.sh /MTC_Agent/
COPY ./Devices/ /MTC_Agent/
COPY --from=alpine-core app_build/schemas/ /MTC_Agent/schemas
COPY --from=alpine-core app_build/simulator/ /MTC_Agent/simulator
COPY --from=alpine-core app_build/styles/ /MTC_Agent/styles
# COPY --from=alpine-core app_build/agent/agent /MTC_Agent/

# Set permission on the folder
RUN chmod +x /MTC_Agent/agent && \
	chmod +x /MTC_Agent/docker-entrypoint.sh

ENTRYPOINT ["/bin/sh", "-x", "/MTC_Agent/docker-entrypoint.sh"]
### EOF
