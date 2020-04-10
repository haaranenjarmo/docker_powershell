FROM alpine:3.11

LABEL Author="Jarmo Haaranen" \
    Twitter="@HaaranenJarmo" \
    Email="jarmo[at]haaranen.net"

ENV PS_MAJOR=7
ENV PS_MINOR=0
ENV PS_PATCH=0
ENV PS_URL=https://github.com/PowerShell/PowerShell/releases/download/v${PS_MAJOR}.${PS_MINOR}.${PS_PATCH}/powershell-${PS_MAJOR}.${PS_MINOR}.${PS_PATCH}-linux-alpine-x64.tar.gz
ENV PS_TEMP_FILE=/tmp/powershell.tar.gz
ENV PS_HOME=/opt/microsoft/powershell/${PS_MAJOR}
ENV PS_BIN=${PS_HOME}/pwsh
ENV PS_USER=powershell
ENV PS_GROUP=powershell

# Create a group and user
RUN addgroup -S ${PS_GROUP} && adduser -S ${PS_USER} -G ${PS_GROUP}

RUN apk add --no-cache ca-certificates less ncurses-terminfo-base krb5-libs \
    libgcc libintl libssl1.1 libstdc++ tzdata userspace-rcu zlib icu-libs curl

#Add lttng-ust package from alpine/edge repo
RUN apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache lttng-ust

#Install PowerShell
RUN curl -L ${PS_URL} -o ${PS_TEMP_FILE} \
    && mkdir -p ${PS_HOME} \
    && tar zxf ${PS_TEMP_FILE} -C ${PS_HOME} \
    && rm -f ${PS_TEMP_FILE} \
    && chmod +x ${PS_BIN} \
    && ln -s ${PS_BIN} /usr/bin/pwsh

#Set PSGallery as trusted repository and install Azure modules to all users scope
RUN pwsh -NoProfile -ExecutionPolicy ByPass -Command Set-PSRepository -Name PSGallery -InstallationPolicy Trusted \
    && pwsh -NoProfile -ExecutionPolicy ByPass -Command Install-Module -Name Az -Scope AllUsers

# Tell docker that all future commands should run as the appuser user
USER ${PS_USER}