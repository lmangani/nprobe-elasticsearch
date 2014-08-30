# What is nProbe?
[nProbe™ v6 An Extensible NetFlow v5/v9/IPFIX GPL Probe for IPv4/v6](http://www.ntop.org/products/nprobe/)

# What is ELK?
[Elasticsearch-Logstash-Kibana Stack](http://www.elasticsearch.org/overview/)

# Setup

This script will (in random order) :

- Install ELK Stack (ElasticSearch + LogStash + Kibana) in single-node
- Install nProbe (unlicensed binary)
- Configure Logstash to receive/parse nProbe JSON received on port TCP 5656



The entire setup has been automated for Ubuntu. Simply run the following commands:

```
$ git clone https://github.com/lmangani/nprobe-ELK.git
$ cd nprobe-ELK
$ chmod +x elk-ubuntu.sh
$ sudo ./elk-ubuntu.sh
```

If you're on stock debian, use the following commands instead:

```
$ git clone https://github.com/lmangani/nprobe-ELK.git
$ cd nprobe-ELK
$ chmod +x elk-debian.sh
$ sudo ./elk-debian.sh
```

Once installed, you should be set to run nProbe:

```
$ nprobe --version
```

You can now use nProbe to send data to your ELK stack:
```
$ nprobe -T "%IPV4_SRC_ADDR %L4_SRC_PORT %IPV4_DST_ADDR %L4_DST_PORT %PROTOCOL %IN_BYTES %OUT_BYTES %FIRST_SWITCHED %LAST_SWITCHED %HTTP_SITE %HTTP_RET_CODE %IN_PKTS %OUT_PKTS %IP_PROTOCOL_VERSION %APPLICATION_ID %L7_PROTO_NAME %ICMP_TYPE" --tcp "127.0.0.1:5656" -b 2 -i any --json-labels
```
