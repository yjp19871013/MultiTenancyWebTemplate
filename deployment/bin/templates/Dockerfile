FROM ubuntu:latest
RUN apt-get update
RUN apt-get install ca-certificates -y
COPY ["bin/", "/app/bin/"]
WORKDIR /app/bin/
ENTRYPOINT [ "/app/bin/{{ .ProjectConfig.BuildName }}" ]
