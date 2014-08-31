# nProbe-ElasticSearch
This project brings nProbe metrics into ELK stack(s) for code development, data modeling and dashboard prototyping.

## What is nProbe?
[nProbe™ v6 An Extensible NetFlow v5/v9/IPFIX GPL Probe for IPv4/v6](http://www.ntop.org/products/nprobe/)  [(ntop.org)](http://www.ntop.org/)

## What is ELK?
[Elasticsearch-Logstash-Kibana Stack (elasticsearch.org)](http://www.elasticsearch.org/overview/)

## Setup

The provided script(s) will :

- Install ELK Stack (ElasticSearch + LogStash + Kibana) in single-node
- Install nProbe (unlicensed binary)
- Configure Logstash to receive/parse nProbe JSON (TCP port 5656)
- Install custom Kibana Dashboards for nProbe metrics (/dashboards)



The entire setup has been automated for Ubuntu and Debian. Simply run the following commands:

```
$ git clone https://github.com/lmangani/nprobe-ELK.git
$ cd nprobe-ELK
$ chmod +x elk-nprobe.sh
$ sudo ./elk-nprobe.sh
```

Once installed, you should be set to run nProbe:

```
$ nprobe --version
```

## Run
You can now use nProbe to send data to your ELK stack:
```
$ nprobe -T "%IPV4_SRC_ADDR %L4_SRC_PORT %IPV4_DST_ADDR %L4_DST_PORT %PROTOCOL %IN_BYTES %OUT_BYTES %FIRST_SWITCHED %LAST_SWITCHED %HTTP_SITE %HTTP_RET_CODE %IN_PKTS %OUT_PKTS %IP_PROTOCOL_VERSION %APPLICATION_ID %L7_PROTO_NAME %ICMP_TYPE %SRC_IP_COUNTRY %DST_IP_COUNTRY %APPL_LATENCY_MS" --tcp "127.0.0.1:5656" -b 1 -i any --json-labels -t 60
```
