FROM containers.intersystems.com/intersystems/iris-community:latest-preview AS iris

FROM jupyter/base-notebook

# install requirements
COPY requirements.txt "${HOME}"
RUN pip install -r requirements.txt

# install IRIS driver
COPY --from=iris /usr/irissys/dev/python/*.whl /tmp/lib/
RUN pip install /tmp/lib/*

# copy notebooks
COPY --chown=jovyan demo "${HOME}/demo"

# run without password
CMD start.sh jupyter lab --LabApp.token='' --notebook-dir="~/demo/"
