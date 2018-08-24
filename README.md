# Introducing the sps_filesync gem

To sync a file between 2 different nodes you will need to set up the following:

* an **SPS broker** to publish to the subscriber that a file has been written, copied, move, or removed
* a **DRb_fileserver_plus** service which acts like a DRB_fileserver, is fault tolerant to node failure and publishes an SPS message to the SPS broker whenever a file is modified
* a **DRb_filesync** service to listen for file changes and perform the same file operation on each of the other nodes
* a **DRb_fileserver** for each node
* a node (machine) containing a copy of the file directory from the other node.

## Starting the SPS broker

    require 'simplepubsub'

    SimplePubSub::Broker.start port: '59000'

## Starting a DRb_fileserver on node 1

Ensure the service is started in the directory containing the files to be synchronised.

    require 'drb_fileserver'

    DRbFileServer.new(host: '0.0.0.0').start

## Starting a DRb_fileserver on node 2

Ensure the service is started in the directory containing a copy of the files from node 1.

    require 'drb_fileserver'

    DRbFileServer.new(host: '0.0.0.0').start

## Starting the DRb_fileserver_plus service

This can be run on any box and it is recommended it doesn't run on the same box as either node 1 or node 2 to avoid port conflicts.

    # host used in this example is 192.168.4.135

    require 'sps_filesync'

    SpsFileSync.new(['192.168.4.177', '192.168.4.20'], host: 'sps').subscribe

Note: All available nodes should be added to the list, including the master node as the service will identify using the SPS message payload which node is the master.


## Running the example

Using the DRb_fileserver_plus service as the DRb fileserver write "hello world" to a file called *hello.txt*.

    require 'drb_fileclient'

    DfsFile.write('dfs://192.168.4.135/hello.txt', 'hello world')

### Observations

* A file called hello.txt should now be observed in both nodes 1 (192.168.4.177) and 2 (192.168.4.20).

The diagram below illustrates the flow of messages throughout the different stages of writing and syncronising files.

![Diagram of the SPS file sync stages](http://a0.jamesrobertson.eu/r/images/2018/aug/24/sps_filesync-diagram.png)

Note: At stage 2 where the file is written, both steps 3 and 4 are triggered at once since they are independent of each other.

## Resources

* sps_filesync https://rubygems.org/gems/sps_filesync

drb_filesync gem drb sps fileserver server service sync
