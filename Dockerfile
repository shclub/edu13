FROM eclipse-temurin:17.0.2_8-jdk AS base
############ [Build] #####################
FROM base AS build-base
# Installing basic packages
RUN apt-get update && \
   apt-get install -y zip unzip curl && \
   apt-get install -y docker && \
   rm -rf /var/lib/apt/lists/* && \
   rm -rf /tmp/*
# Downloader
FROM build-base AS downloader
WORKDIR /downloads
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
RUN curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
install skaffold /usr/local/bin/
RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-20.10.7.tgz | tar zxvf - --strip 1 -C /usr/local/bin docker/docker
############ [Production] #####################
### Runtime
FROM base AS production
RUN apt-get update && \
   apt-get install -y git && \
   rm -rf /var/lib/apt/lists/* && \
   rm -rf /tmp/*
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
COPY --from=downloader /usr/local/bin/skaffold /usr/local/bin/skaffold
COPY --from=downloader /downloads/kustomize /usr/local/bin/kustomize
COPY --from=downloader /usr/local/bin/docker /usr/local/bin/docker
RUN mkdir -p /root/.m2
###COPY ./settings.xml /root/.m2
