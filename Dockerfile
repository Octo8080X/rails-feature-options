# 使いたいバージョン次第で書き換える https://hub.docker.com/_/ruby
FROM ruby:3.4.4

WORKDIR /usr/src/app

# 3000番ポートを解放
EXPOSE 3000