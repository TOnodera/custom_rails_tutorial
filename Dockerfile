FROM ruby:2.7-alpine

ENV HOST_UID=1000

RUN apk update \
    && apk add -y --no-cache tzdata bash git curl sqlite make g++ sqlite-dev \
    && adduser -u ${HOST_UID} -s /bin/bash --disabled-password --gecos "" ruby

WORKDIR /home/ruby/app
COPY . /home/ruby/app
ENV TZ="Asia/Tokyo"
EXPOSE 8000

CMD ['ruby','/home/ruby/server.rb']