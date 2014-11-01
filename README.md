# nProbe-ElasticSearch
This project brings nProbe metrics into Elasticsearch for development, data modeling and prototyping.

## What is nProbe?
[nProbe™ v6 An Extensible NetFlow v5/v9/IPFIX GPL Probe for IPv4/v6](http://www.ntop.org/products/nprobe/)  [(ntop.org)](http://www.ntop.org/)

## What is Elasticsearch?
[Elasticsearch (elasticsearch.org)](http://www.elasticsearch.org/overview/)


## Setup

The provided script(s) will :

- Install Elastichsearch (ElasticSearch) in single-node
- Install QBana (nProbe's Kibana fork) served by nginx
- Install nProbe w/ Elasticsearch Bulk JSON output (unlicensed binary)


#### Note for Existing ELK/nProbe users:
If you have an existing ELK setup you wish to integrate with nProbe reports, just point nProbe at your Elasticsearch BULK API

#### New Users/Fresh Setup:

The entire setup has been automated for Ubuntu and Debian. Simply run the following commands:

```
$ git clone https://github.com/lmangani/nprobe-elasticsearch
$ cd nprobe-elastichsearch
$ chmod +x elk-nprobe.sh
$ sudo ./elk-nprobe.sh
```

Once installed, you should be all set. If you already have an ELK setup, just copy conf.d/nprobe.conf to your logstash settings and install nProbe only, adjusting the below settings.

Verify nProbe is functioning:

```
$ nprobe --version
```

Verify EL(q) is up:
```
# /etc/init.d/elasticsearch status
[ ok ] elasticsearch is running.
# curl --head http://localhost/qbana
HTTP/1.1 200 OK
...

```

## Run
You can now use nProbe to send data to Elasticsearch's BULK Indexing API:
```
$ nprobe -T "%IPV4_SRC_ADDR %L4_SRC_PORT %IPV4_DST_ADDR %L4_DST_PORT %PROTOCOL %IN_BYTES %OUT_BYTES %FIRST_SWITCHED %LAST_SWITCHED %IN_PKTS %OUT_PKTS %IP_PROTOCOL_VERSION %APPLICATION_ID %L7_PROTO_NAME %ICMP_TYPE %SRC_IP_COUNTRY %DST_IP_COUNTRY %APPL_LATENCY_MS" --redis localhost --elastic "nProbe;nprobe;http://127.0.0.1:9200/_bulk" -b 1 -i any --json-labels -t 60
```

## Play
Go to http://{your_host_ip}/qbana to start playing with the generated data and using the example dashboards

## Todo:
- HA/Distributed setup / docker (coming soon)
- More Dashboards! (contributions/ideas are welcome)



