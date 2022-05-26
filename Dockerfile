#!/bin/sh
### Alpine Version


# ---- alpine glibc instance ----
FROM alpine:latest AS alpine-base


# ---- alpine make ----
# Get and install glibc for alpine
FROM alpine-base AS alpine-core
RUN apk upgrade \
	&& apk add g++ python3 cmake git linux-headers make perl ruby

RUN git clone --recurse-submodules --progress https://github.com/mtconnect/cppagent.git --depth 1 /app_build/

RUN python3 -m ensurepip \
	&& python3 -m pip install --upgrade pip \
	&& export PATH=~/.local/bin:$PATH \
	&& pip3 install conan \
	&& cd /app_build/ \
	&& conan export conan/mqtt_cpp/ \
	&& conan export conan/mruby/ \
	&& conan install . -if build --build=missing -pr conan/profiles/docker

RUN	cd /app_build/ \
	&& conan build . -bf build


# ---- Release ----
### Create folders, copy device files and dependencies for the release
FROM alpine-base AS alpine-release
LABEL author="skibum1869" description="Docker image for the latest MTConnect C++ Agent supplied \
from the MTConnect Institute"
EXPOSE 5000:5000/tcp

RUN	apk add --no-cache \
	libstdc++ \
	libc6-compat

WORKDIR /MTC_Agent/
COPY agent.cfg /MTC_Agent/
COPY docker-entrypoint.sh /MTC_Agent/
COPY ./mtconnect-devicefiles/Devices/ /MTC_Agent/devices
COPY ./mtconnect-devicefiles/Assets/ /MTC_Agent/assets
COPY --from=alpine-core app_build/schemas/ /MTC_Agent/schemas
COPY --from=alpine-core app_build/simulator/ /MTC_Agent/simulator
COPY --from=alpine-core app_build/styles/ /MTC_Agent/styles
COPY --from=alpine-core app_build/build/bin/agent /MTC_Agent/agent
RUN chmod +x /MTC_Agent/agent && \
	chmod +x /MTC_Agent/docker-entrypoint.sh

# ENTRYPOINT ["/bin/sh", "-x", "/MTC_Agent/docker-entrypoint.sh"]


### EOF
