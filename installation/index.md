---
---

This document explains how to install and configure all the essential components Histograph needs to run:

  1. Install Neo4j
  2. Install Elasticsearch
  3. Install Redis
  4. Install Histograph
  5. Create and import data files

## Neo4j

### Installation

[Download and install Neo4j](http://neo4j.com/download/), or use your favorite package manager. Or Homebrew:

    brew install neo4j

### Configuration

Histograph currently expects Neo4j server to run without authentication. You can disable authentication by editing `neo4j-server.properties`, and adding the following line:

    dbms.security.auth_enabled=false

With a Homebrew-installed Neo4j, this file is located here:

    /usr/local/Cellar/neo4j/:version/libexec/conf/neo4j-server.properties

In debian you will find it here:
    `/etc/neo4j`

### Histograph Neo4j plugin

Histograph depends on a [server plugin](https://github.com/histograph/neo4j-plugin) for some of its graph queries. You can install this plugin like this:

{% highlight bash %}
git clone https://github.com/histograph/neo4j-plugin.git
cd neo4j-plugin
./install.sh
{% endhighlight %}

This script is for OSX, on other systems, run `mvn package` yourself to build the Neo4j plugin, copy the resulting JAR file to Neo4j's plugin directory, and restart Neo4j. 

In a debian install, the plugin is at:
  `/usr/share/neo4j`

## Elasticsearch

### Installation

Install [Elasticsearch](https://www.elastic.co/downloads/elasticsearch). With Homebrew, this is easy:

    brew install elasticsearch

### Configuration

Enable CORS, add the following lines to `elasticsearch.yml`, in the `config` directory of your Elasticsearch installation:

{% highlight yaml %}
http.cors.enabled: true
http.cors.allow-origin: "*"
http.cors.allow-methods: OPTIONS, HEAD, GET, POST, PUT, DELETE
http.cors.allow-headers: X-Requested-With,X-Auth-Token,Content-Type, Content-Length
{% endhighlight %}

With Homebrew, this file is located here:

    /usr/local/Cellar/elasticsearch/:version/config

Afterwards, put Histograph's `default-mapping.json` in the `config` directory, too:

{% highlight bash %}
wget https://raw.githubusercontent.com/histograph/schemas/graphmalizer/elasticsearch/default-mapping.json
mv default-mapping.json /usr/local/Cellar/elasticsearch/:version/config
{% endhighlight %}

## Redis

With Homebrew `brew install redis`, [redis.io](http://redis.io/download) otherwise.

## Histograph

### Schemas

First of all, create a directory somewhere to contain all Histograph runtime and configuration files. Now, we can start by downloading the schemas repository, which contains Histograph's configurable data model:

    git clone https://github.com/histograph/schemas
    npm install

The most important file in this repository is `histograph.ttl`, the Histograph ontology. This file contains all types and relations used by Histograph Core, API and import scripts. You can edit the ontology and add your own types and relations, and run `node schemas-from-ontology.js` afterwards to create JSON schemas from the changed ontology.

### Configuration

All Histograph components depend on a single JSON configuration file, and expect the environment variable `HISTOGRAPH_CONFIG` to contain the absolute path to this file:

    git clone https://github.com/histograph/config
    cd config
    cp histograph.example.json histograph.json
    export HISTOGRAPH_CONFIG=path/to/config/histograph.json

Before running Histograph, you will need to change some parts of `histograph.json`:

{% highlight js %}
{
  "api": {
    "protocol": "http",
    "host": "localhost",                // localhost, or hostname of server.
    "dataDir":
        "/usr/local/histograph/data",   // Directory where API stores data files.
    "externalPort": 80,
    "internalPort": 3000,
    "admin": {
      "name": "histograph",             // Default Histograph user, is created
      "password": "Your password!! 🚜"  //   when starting API the first time.
    }
  },
  "import": {
    "dirs": [
      "../data",                        // List of directories containing
      "..."                             //   Histograph datasets.
    ]
  },
  "schemas": {
    "dir":
        "/usr/local/histograph/schemas" // Absolute or relative path to
  }                                     //  Histograph schemas.
}
{% endhighlight %}

### Core

Histograph Core reads messages from Redis, and syncs Neo4j and Elasticsearch.

    git clone https://github.com/histograph/core.git
    cd core
    npm install
    node index.js -q histograph \
      --config path/to/schemas/graphmalizer/graphmalizer.config.json

### API

Histograph API exposes a search and dataset API, allows users to upload datasets, and writes messages to the Redis queue.

    git clone https://github.com/histograph/api.git
    cd api
    npm install
    node index.js

Afterwards, the API will be available on [http://localhost:3000](http://localhost:3000).

### Download or create NDJSON files

A Histograph dataset consists of a directory containing three files: two NDJSON files containing the dataset's PITs and relations, and a JSON file containing dataset metadata.

- Use [Histograph Data](https://github.com/histograph/data) to download and create NDJSON files from sources like the [Getty Thesaurus of Geographic Names](getty.edu/research/tools/vocabularies/tgn/) and [GeoNames](http://www.geonames.org/).
- [Heritage & Location datasets](https://github.com/erfgoed-en-locatie/data)
- Or, you can create NDJSON files yourself, from your own data.

To use Histograph Data to download and compile a default set of Histograph NDJSON files, do the following:

    git clone https://github.com/histograph/data.git
    cd data
    npm install
    node index.js tgn geonames

### Import data

    git clone https://github.com/histograph/import.git
    cd import
    npm install
    node index.js tgn geonames
