# IRIS Waveform demo

This demonstration project stores High Frequency Data (HFD) extracted from HL7 messages and stores it in a custom data structure that projects to SQL for easy query access. 

:information_source: The prototype presented in this repository is based on existing InterSystems IRIS functionality, including the `$vector` language feature and custom SQL mappings. It has been successfully deployed in several environments, and can offer a basis for your own HFD or general time series explorations. We welcome any feedback and pull requests to improve the published code, and review opportunities for further integration into the InterSystems IRIS Data Platform itself.


## Installing the demo

### OPTION 1: Using Docker compose

First clone the repository locally, navigate to the root folder and launch the docker containers:

```Shell
docker-compose build
docker-compose up
```

This demo launches three different containers:
* the [main IRIS instance](http://localhost:9991/csp/sys/UtilHome.csp) holding the waveform data, listening for new messages over TCP
* a [secondary IRIS instance](http://localhost:9992/csp/sys/UtilHome.csp) to drive load, reading HL7 messages from disk and sending them to the main IRIS instance
* a [Jupyter notebook](http://localhost:9993/lab/tree/basic-demo.ipynb) container holding the demo notebook

See `docker-compose.yml` for more about the port mappings.


### OPTION 2: Add Waveform processor to your own IRIS instance

Use [IPM / ZPM](https://github.com/intersystems/ipm) to install the Waveform processor package:

```
USER> zpm "install hfd-main"
```


## Getting the data in

There are two ways to ingest data: using the driver, the secondary IRIS instance that simulates actual medical devices that send HL7 messages to the main IRIS instance over TCP, or using a bulk load utility to read HL7 files directly from disk on the main IRIS instance. Either way, you'll need a fair volume of HL7 messages with waveform and/or parameter data that are fit for a demo (no PII!). 
Demo datasets are currently not part of the demo, but we'll assume you have them in a `./data` directory.

### Loading over TCP

This is meant to be the realistic scenario, in which "some number of devices" (or concentrators grouping signals from devices) are sending HL7 data to the main IRIS instance using the TCP protocol. The driver instance simulating this load in practice is loading this HL7 data from disk to ensure we're using realistic messages, so in a benchmarking scenario you would run this driver on a separate machine, and ideally have a bunch of them to try and saturate the main instance rather than depend on the driver instance's IO capacity.

Use `docker cp` to get the data onto the main IRIS instance, ideally separating parameter and waveform messages:

```Shell
docker cp ./data/meta/ waveform-demo-driver-1:/data/meta/
docker cp ./data/wave/ waveform-demo-driver-1:/data/wave/
```

The driver instance is pretty autonomous, and has a small production that starts automatically, reads the files from disk and puts them on the (TCP) wire to the main IRIS instance.

On the main IRIS instance, there's another basic production running that has Business Services listening on the TCP ports and should automatically ingest them into the target data structures.


### Bulk load from disk

Use `docker cp` to get the data onto the main IRIS instance and then log in:

```Shell
docker cp ./data/ waveform-demo-iris-1:/data/in/
docker exec -it waveform-demo-iris-1 iris session iris
```

Now load the data using the `HFD.Ingest` class, whose `LoadDir()` method takes three arguments:
* directory to load from
* whether or not to recurse into subdirectories
* whether or not to clean out existing data upfront
* number of jobs to use for loading

For example:

```ObjectScript
do ##class(HFD.Ingest).LoadDir("/data/in/", 1, 1, 4)
```

## Reviewing the demo notebook

When you deployed the demo using `docker-compose`, a container running Jupyter will have been launched, from which you can consult this simple [demo notebook](hhttp://localhost:9993/lab/tree/basic-demo.ipynb), which walks you through a few simple queries and charts plotting the retrieved HFD series.

If you deployed using `ipm`, you can run the notebook at `jupyter/demo/basic-demo.ipynb` using your local Jupyter.

## Have questions?

Just post an issue in this repository, and we'd be happy to help out!