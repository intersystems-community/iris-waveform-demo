# iris-waveform-demo
Demonstration project storing HL7 time series data in an easily queriable format on IRIS


## OPTION 1: Clone this Repository Locally and use the Docker compose file

```Shell
docker-compose build
docker-compose up
```

This demo launches three different containers:
* the [main IRIS instance](http://localhost:9991/csp/sys/UtilHome.csp) holding the waveform data, listening for new messages over TCP
* a [secondary IRIS instance](http://localhost:9992/csp/sys/UtilHome.csp) to drive load, reading HL7 messages from disk and sending them to the main IRIS instance
* a [Jupyter notebook](http://localhost:9993/lab) container holding the demo notebook

See `docker-compose.yml` for more about the port mappings

## OPTION 2: Add Waveform processor to your own IRIS instance

Use [IPM / ZPM](https://github.com/intersystems/ipm) to install the Waveform processor package. It only needs to be installed in one namespace, from where it can generate documentation for any namespace. Choose an interop-enabled namespace if you want to document any interop applications. We suggest picking the USER namespace:

```Shell
USER>zpm "install hfd-main"
```


## Getting the data in

There are two ways to ingest data: using the driver, the secondary IRIS instance that simulates actual medical devices, sending HL7 messages to the main IRIS instance over TCP, or using a bulk load utility to read HL7 files directly from disk on the main IRIS instance. Either way, you'll need a fair volume of HL7 messages with waveform and/or parameter data that are fit for a demo (no PII!). Demo datasets are currently not part of the demo, but we'll assume you have them in a `./data` directory.

### Loading over TCP

This is meant to be the realistic scenario, in which "some number of devices" (or concentrators grouping signals from devices) are sending HL7 data to the main IRIS instance using the TCP protocol. The driver instance simulating this load in practice is loading this HL7 data from disk to ensure we're using realistic messages, so in a benchmarking scenario you would run this driver on a separate machine, and ideally have a bunch of them to try and saturate the main instance rather than depend on the driver instance's IO capacity.


Use `docker cp` to get the data onto the main IRIS instance, ideally separating parameter and waveform messages:

```Shell
docker cp ./data/meta/ waveform-demo-driver-1:/data/meta/
docker cp ./data/wave/ waveform-demo-driver-1:/data/wave/
```

The driver instance is pretty autonomous, and has a small automatically starting production reading the files from disk and putting them on the (TCP) wire.

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

```ObjectScript
do ##class(HFD.Ingest).LoadDir("/data/in/", 1, 1, 4)
```