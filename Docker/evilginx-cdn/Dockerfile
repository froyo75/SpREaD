ARG EVILGINX_BIN="/bin/evilginx"

# Stage 1 - Build EvilGinx3 app
FROM alpine:latest AS build

LABEL maintainer="froyo75@users.noreply.github.com"

ARG GOLANG_VERSION=1.22.2
ARG GOPATH=/opt/go
ARG GITHUB_USER="kgretzky"
ARG EVILGINX_REPOSITORY="github.com/${GITHUB_USER}/evilginx2"
ARG INSTALL_PACKAGES="go git bash"
ARG PROJECT_DIR="${GOPATH}/src/${EVILGINX_REPOSITORY}"
ARG EVILGINX_BIN
# For self-signed certificate
ARG ORGANISATION_NAME="SpREaD Corp"
ARG COMMON_NAME="SpREaD CA"
RUN apk add --no-cache ${INSTALL_PACKAGES}

# Install & Configure Go
RUN set -ex \
    && wget https://go.dev/dl/go${GOLANG_VERSION}.src.tar.gz && tar -C /usr/local -xzf go$GOLANG_VERSION.src.tar.gz \
    && rm go${GOLANG_VERSION}.src.tar.gz \
    && cd /usr/local/go/src && ./make.bash \
# Clone EvilGinx3 Repository
    && mkdir -pv ${GOPATH}/src/github.com/${GITHUB_USER} \
    && git -C ${GOPATH}/src/github.com/${GITHUB_USER} clone https://${EVILGINX_REPOSITORY}

# Remove IOCs
## Remove the Evilginx header
RUN set -ex \
    && sed -i -e 's/req.Header.Set(p.getHomeDir(), o_host)/\/\/req.Header.Set(p.getHomeDir(), o_host)/g' ${PROJECT_DIR}/core/http_proxy.go
## Rename the selfsigned certificate used in developer mode (Thx to @Dreyvor - https://github.com/Dreyvor)
RUN set -ex \
   && sed -i -e "s/Evilginx Signature Trust Co./${ORGANISATION_NAME}/g" \
   -e "s/Evilginx Super-Evil Root CA/${COMMON_NAME}/g" ${PROJECT_DIR}/core/certdb.go

# Add "security" & "tech" TLD
RUN set -ex \
    && sed -i 's/arpa/security\|arpa/g' ${PROJECT_DIR}/core/http_proxy.go

# Add date to EvilGinx3 log
RUN set -ex \
    && sed -i 's/"%02d:%02d:%02d", t.Hour()/"%02d\/%02d\/%04d - %02d:%02d:%02d", t.Day(), int(t.Month()), t.Year(), t.Hour()/g' ${PROJECT_DIR}/log/log.go

# Build EvilGinx3
ENV PATH="/usr/local/go/bin:$PATH"
WORKDIR ${PROJECT_DIR}
RUN set -x \
    && go get -v && go build -v \
    && cp -v evilginx2 ${EVILGINX_BIN} \
    && mkdir -v /app

# Stage 2 - Build Runtime Container
FROM alpine:latest

LABEL maintainer="froyo75@users.noreply.github.com"

ENV EVILGINX_PORTS="443 80 53/udp"
ARG EVILGINX_BIN

RUN apk add --no-cache bash && mkdir -v /app

# Install EvilGinx3
WORKDIR /app
COPY --from=build ${EVILGINX_BIN} ${EVILGINX_BIN}
COPY --from=build /app .

# Configure Runtime Container
EXPOSE ${EVILGINX_PORTS}

CMD [${EVILGINX_BIN}, "-p", "/app/phishlets", "-developer", "-t", "/app/redirectors"]
