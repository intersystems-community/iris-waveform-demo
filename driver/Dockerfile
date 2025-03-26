# Dockerfile for the driver instance, which will feed the main IRIS server
ARG IMAGE=containers.intersystems.com/intersystems/irishealth-community:latest-preview

FROM ${IMAGE}

USER root
WORKDIR /opt/irisbuild
RUN chown irisowner:irisowner /opt/irisbuild

RUN mkdir /data /data/wave /data/meta && \
    chown -R irisowner:irisowner /data

USER irisowner

# IRIS setup
COPY --chown=irisowner:irisowner iris.script ./ ./
RUN iris start IRIS && \
    iris session IRIS < iris.script && \
    iris stop IRIS quietly