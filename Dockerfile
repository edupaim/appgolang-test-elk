# final stage
FROM ubuntu:bionic
WORKDIR /app
COPY ./bin/app-log /app/
ENTRYPOINT ["/app/app-log"]