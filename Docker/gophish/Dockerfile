ARG GOPHISH_BIN="/bin/gophish"

# Stage 1 - Build GOPHISH app
FROM alpine:latest AS build

LABEL maintainer="froyo75@users.noreply.github.com"

ARG GOLANG_VERSION=1.16
ARG GOPATH=/opt/go
ARG GITHUB_USER="gophish"
ARG GOPHISH_REPOSITORY="github.com/${GITHUB_USER}/gophish"
ARG INSTALL_PACKAGES="go git bash npm"
ARG PROJECT_DIR="${GOPATH}/src/${GOPHISH_REPOSITORY}"
ARG GOPHISH_BIN
ARG RECIPIENT_PARAMETER
ARG TRACK_PARAMETER

RUN apk add --no-cache ${INSTALL_PACKAGES}

# Install & Configure Go
RUN set -ex \
    && wget https://dl.google.com/go/go${GOLANG_VERSION}.src.tar.gz && tar -C /usr/local -xzf go$GOLANG_VERSION.src.tar.gz \
    && rm go${GOLANG_VERSION}.src.tar.gz \
    && cd /usr/local/go/src && ./make.bash \
# Clone GOPHISH Repository
    && mkdir -pv ${GOPATH}/src/github.com/${GITHUB_USER} \
    && git -C ${GOPATH}/src/github.com/${GITHUB_USER} clone https://${GOPHISH_REPOSITORY}

# Remove IOCs and customize GOPHISH
WORKDIR ${PROJECT_DIR}
COPY custom/campaign_results.js static/js/src/app/campaign_results.js
# Original from (https://github.com/edermi/gophish_mods/blob/master/controllers/phish.go)
COPY custom/phish.go controllers/phish.go
COPY custom/404.html templates/404.html
RUN set -ex \
    && sed -i 's/SignatureHeader = "X-Gophish-Signature"/SignatureHeader = "X-Report-Signature"/g' webhook/webhook.go \
    && sed -i 's/"github.com\/gophish\/gophish\/config"/\/\/"github.com\/gophish\/gophish\/config"/g' models/maillog.go \
    && sed -i 's/msg.SetHeader("X-Mailer", config.ServerName)/\/\/msg.SetHeader("X-Mailer", config.ServerName)/g' models/maillog.go \
    && sed -i 's/"X-Gophish-Contact": "",/\/\/"X-Gophish-Contact": "",/g' models/maillog_test.go \
    && sed -i 's/Header{Key: "X-Gophish-Contact", Value: ""},/\/\/Header{Key: "X-Gophish-Contact", Value: ""},/g' models/maillog_test.go \
    && sed -i 's/"X-Gophish-Contact": s.config.ContactAddress,/\/\/"X-Gophish-Contact": s.config.ContactAddress,/g' models/maillog_test.go \
    && sed -i 's/msg.SetHeader("X-Gophish-Contact", conf.ContactAddress)/\/\/msg.SetHeader("X-Gophish-Contact", conf.ContactAddress)/g' models/email_request.go \
    && sed -i 's/"X-Gophish-Contact": s.config.ContactAddress,/\/\/"X-Gophish-Contact": s.config.ContactAddress,/g' models/email_request_test.go \
    && sed -i 's/const ServerName = "gophish"/const ServerName = "IGNORE"/g' config/config.go \
    && sed -i 's/const RecipientParameter = "rid"/const RecipientParameter = "'"${RECIPIENT_PARAMETER}"'"/g' models/campaign.go \
    && sed -i 's/\/track/\/'"${TRACK_PARAMETER}"'/g' models/template_context.go \
    && sed -i 's/\/track/\/'"${TRACK_PARAMETER}"'/g' controllers/phish.go \
    && sed -i 's/ 7/ 40/g' models/result.go \
    && sed -i 's/rid=/'"${RECIPIENT_PARAMETER}"'=/g' static/js/src/app/campaign_results.js \
    && sed -i 's/rid=/'"${RECIPIENT_PARAMETER}"'=/g' static/js/dist/app/campaign_results.min.js

# Build GOPHISH
RUN set -x \
    && go get -v && go build -v \
    && cp -v gophish ${GOPHISH_BIN} \
    && mkdir -v /app \
    && cp -vr db /app \
    && cp -vr static /app \
    && cp -vr templates /app \
    && cp -v config.json /app \
    && cp -v VERSION /app \
    && cp -v LICENSE /app \
# Minify client side assets (JavaScript)
    && npm install gulp gulp-cli -g \
    && npm install --only=dev && gulp \
    && cp -vr ./static/js/dist/ /app/static/js/ \
    && cp -vr ./static/css/dist/ /app/static/css/

# Stage 2 - Build Runtime Container
FROM alpine:latest

LABEL maintainer="froyo75@users.noreply.github.com"

ENV GOPHISH_PORTS="3333 8080"
ARG GOPHISH_USER="gophish"
ARG GOPHISH_BIN

RUN apk add --no-cache bash jq && mkdir -v /app

# Create GOPHISH user
RUN adduser --disabled-password -h /app -s /bin/bash ${GOPHISH_USER}

# Install GOPHISH
WORKDIR /app
COPY --from=build ${GOPHISH_BIN} ${GOPHISH_BIN}
COPY --from=build --chown=${GOPHISH_USER}:${GOPHISH_USER} /app .

# Configure Runtime Container
USER ${GOPHISH_USER}
RUN touch config.json.tmp
COPY --chown=${GOPHISH_USER}:${GOPHISH_USER} run.sh /app
EXPOSE ${GOPHISH_PORTS}

CMD ["./run.sh"]
