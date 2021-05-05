FROM ruby:2.7-alpine

ENV HOST_UID=1000

RUN apk update \
    && apk add -y --no-cache tzdata bash git curl sqlite make g++ sqlite-dev sudo \
    && adduser -u ${HOST_UID} -s /bin/bash --disabled-password --gecos "" -G wheel ruby

RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

WORKDIR /home/ruby/app
COPY . /home/ruby/app
ENV TZ="Asia/Tokyo"
EXPOSE 8000

CMD ['ruby','/home/ruby/server.rb']