#!/bin/sh
### Ubuntu instance

# # ---- Base Node ----
# # This dockerfile defines the expected runtime environment before the project is installed
# FROM ubuntu:latest AS base
# # FROM debian:latest AS base

# # ---- Core ----
# ### Application compile
# FROM base AS core

# ENV DEBIAN_FRONTEND=noninteractive

# RUN apt-get clean \
# 	&& apt-get update \
# 	&& apt-get install -y \
# 	curl
# RUN apt-get clean \
# 	&& apt-get update \
# 	&& apt-get install -y \
# 	curl \
# 	apt-utils \
# 	libxml2-dev \
# 	libcppunit-dev \
# 	build-essential \
# 	make \
# 	cmake \
# 	git \
# 	&& git clone --recurse-submodules https://github.com/mtconnect/cppagent.git /app_build/ \
# 	&& cd /app_build/ \
# 	&& git submodule init \
# 	&& git submodule update \
# 	&& cmake -G 'Unix Makefiles' . \
# 	&& make

# # ---- Release ----
# ### Create folders, copy device files and dependencies for the release
# FROM base AS release
# ENV DEBIAN_FRONTEND=noninteractive
# LABEL author="skibum1869" description="Docker image for the latest MTConnect C++ Agent supplied \
# from the MTConnect Institute"
# EXPOSE 5000:5000/tcp

# # RUN mkdir /MTC_Agent/ 
# # COPY <src> <dest>
# COPY docker-entrypoint.sh /MTC_Agent/
# COPY agent.cfg /MTC_Agent/
# COPY ./Devices/ /MTC_Agent/
# COPY --from=core app_build/schemas/ /MTC_Agent/schemas
# COPY --from=core app_build/simulator/ /MTC_Agent/simulator
# COPY --from=core app_build/styles/ /MTC_Agent/styles
# COPY --from=core app_build/agent/agent /MTC_Agent/agent

# # Set permission on the folder
# RUN ["chmod", "o+x", "/MTC_Agent/"]
# ### EOF


### Alpine Version
# ---- alpine glibc instance ----
### alpine glibc instance
FROM alpine:latest AS alpine-core
# Get and install glibc for alpine
ARG APK_GLIBC_VERSION=2.32-r0
ARG APK_GLIBC_FILE="glibc-${APK_GLIBC_VERSION}.apk"
ARG APK_GLIBC_BIN_FILE="glibc-bin-${APK_GLIBC_VERSION}.apk"
ARG APK_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${APK_GLIBC_VERSION}"
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget "${APK_GLIBC_BASE_URL}/${APK_GLIBC_FILE}"       \
    && apk --no-cache add "${APK_GLIBC_FILE}"               \
    && wget "${APK_GLIBC_BASE_URL}/${APK_GLIBC_BIN_FILE}"   \
    && apk --no-cache add "${APK_GLIBC_BIN_FILE}"           \
    && rm glibc-*
RUN	apk add --no-cache \
	curl \
	wget \
	ca-certificates

# ---- alpine make ----
### alpine glibc instance
FROM alpine-core AS alpine-make
RUN apk add --no-cache \
	alpine-sdk \
	curl \
	make \
	cmake \
	libxml2-dev \
	libstdc++6 \
	libstdc++ \
	# libc6-compat \
	&& git clone --recurse-submodules https://github.com/mtconnect/cppagent.git /app_build/ \
	&& cd /app_build/ \
	&& git submodule init \
	&& git submodule update \
	&& cmake -G 'Unix Makefiles' --config Release . \
	&& make


# ---- Release ----
### Create folders, copy device files and dependencies for the release
FROM alpine-core AS release
LABEL author="skibum1869" description="Docker image for the latest MTConnect C++ Agent supplied \
from the MTConnect Institute"
EXPOSE 5000:5000/tcp

## for testing alpine release
# RUN apk add --no-cache \
# 	curl \
# 	libxml2-dev \
# 	libc6-compat \
# 	libstdc++

# RUN mkdir /MTC_Agent/ 
# COPY <src> <dest>
COPY docker-entrypoint.sh /MTC_Agent/
COPY agent.cfg /MTC_Agent/
COPY ./Devices/ /MTC_Agent/
## Ubuntu Build
# COPY --from=core app_build/schemas/ /MTC_Agent/schemas
# COPY --from=core app_build/simulator/ /MTC_Agent/simulator
# COPY --from=core app_build/styles/ /MTC_Agent/styles
# COPY --from=core app_build/agent/agent /MTC_Agent/agent
## Alpine Build
COPY --from=alpine-make app_build/schemas/ /MTC_Agent/schemas
COPY --from=alpine-make app_build/simulator/ /MTC_Agent/simulator
COPY --from=alpine-make app_build/styles/ /MTC_Agent/styles
COPY --from=alpine-make app_build/agent/agent /MTC_Agent/agent

# Set permission on the folder
RUN ["chmod", "o+x", "/MTC_Agent/"]
### EOF
