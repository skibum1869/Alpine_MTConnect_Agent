#!/bin/sh
### Alpine Version
# ---- alpine glibc instance ----
### alpine glibc instance
FROM alpine:latest AS alpine-base

# ---- alpine make ----
### alpine glibc instance

# Get and install glibc for alpine
FROM alpine-base AS alpine-core

## Removed not needed
# RUN	apk add --no-cache \
# 	curl \
# 	wget \
# 	ca-certificates \
# 	libxml2-dev \
# 	libstdc++ \
# 	gcc \
# 	alpine-sdk \
# 	curl \
# 	make \
# 	cmake \
# 	libstdc++6 
# ARG APK_GLIBC_VERSION=2.32-r0
# ARG APK_GLIBC_FILE="glibc-${APK_GLIBC_VERSION}.apk"
# ARG APK_GLIBC_BIN_FILE="glibc-bin-${APK_GLIBC_VERSION}.apk"
# ARG APK_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${APK_GLIBC_VERSION}"
# RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
#     && wget "${APK_GLIBC_BASE_URL}/${APK_GLIBC_FILE}"       \
#     && apk --no-cache add "${APK_GLIBC_FILE}"               \
#     && wget "${APK_GLIBC_BASE_URL}/${APK_GLIBC_BIN_FILE}"   \
#     && apk --no-cache add "${APK_GLIBC_BIN_FILE}"           \
#     && rm glibc-*

## Testing to see if the code above is not needed 
RUN apk upgrade \
	&& apk add git \
	python3 \
	cmake \
	g++ \
	make

# Install and run cmake and make components
RUN git clone --recurse-submodules https://github.com/mtconnect/cppagent.git /app_build/ \
	&& cd /app_build/ \
	&& git submodule init \
	&& git submodule update \
	&& cmake -G 'Unix Makefiles' --config Release . 
	# && make ## Commented out untill the DLib.cmake file is corrected for the 64 bit binaries on the cppagent repo from MTConnect Instute

# libc6-compat not needed since it is in the glibc program above.


# ---- Release ----
### Create folders, copy device files and dependencies for the release
FROM alpine-base AS alpine-release
LABEL author="skibum1869@HEM-Inc" description="Docker image for the latest MTConnect C++ Agent supplied \
from the MTConnect Institute"
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
