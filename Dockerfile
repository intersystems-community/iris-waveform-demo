# Dockerfile for the main IRIS instance
ARG IMAGE=containers.intersystems.com/intersystems/irishealth-community:latest-preview

FROM ${IMAGE}

USER root
WORKDIR /opt/irisbuild
RUN chown irisowner:irisowner /opt/irisbuild

RUN mkdir /data /data/in /data/out && \
    chown -R irisowner:irisowner /data

    USER irisowner

# IRIS setup
COPY --chown=irisowner:irisowner ./ ./
RUN iris start IRIS && \
    iris session IRIS < iris.script && \
    iris stop IRIS quietly