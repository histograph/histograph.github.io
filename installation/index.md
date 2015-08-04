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

### Histograph Neo4j plugin

Histograph depends on a [server plugin](https://github.com/histograph/neo4j-plugin) for some of its graph queries. You can install this plugin like this:

{% highlight bash %}
git clone https://github.com/histograph/neo4j-plugin.git
cd neo4j-plugin
./install.sh
{% endhighlight %}

This script is for OSX, on other systems, run `mvn package` yourself to build the Neo4j plugin, copy the resulting JAR file to Neo4j's plugin directory, and restart Neo4j. Plugin under debian is at /usr/share/neo4j

## Elasticsearch

### Installation

Install [Elasticsearch](https://www.elastic.co/downloads/elasticsearch). With Homebrew, this is easy:

    brew install elasticsearch

### Configuration

Currently, Histograph does not create its own mappings. Please put Histograph's `default-mapping.json` in  the `config` directory of your Elasticsearch installation.

With Homebrew, this file is located here:

    /usr/local/Cellar/elasticsearch/:version/config

Download `default-mapping.json` from GitHub, and copy the file:

{% highlight bash %}
wget https://raw.githubusercontent.com/histograph/schemas/graphmalizer/elasticsearch/default-mapping.json
mv default-mapping.json /usr/local/Cellar/elasticsearch/:version/config
{% endhighlight %}

And, add the following lines to `elasticsearch.yml`:

```yml
index.analysis.analyzer.lowercase:
  filter: lowercase
  tokenizer: keyword
```

## Redis

With Homebrew `brew install redis`, [redis.io](http://redis.io/download) otherwise.

## Histograph

### Configuration

All Histograph components depend on the [histograph-config](https://github.com/histograph/config) module, which  specifies a set of (overridable) default options. However, some options must always be specified manually: histograph-config loads the default configuration from [`histograph.default.yml`](https://github.com/histograph/config/blob/master/histograph.default.yml) and merges this with a required user-specified configuration file. You can specify the location of your own configuration file in two ways:

1. Start the Histograph module with the argument `--config path/to/config.yml`
2. Set the `HISTOGRAPH_CONFIG` environment variable to the path of the configuration file:

```bash
export HISTOGRAPH_CONFIG=/Users/bert/code/histograph/config/histograph.bert.yml
```

This configuration file should at least specify the following options:

```yml
api:
  dataDir: /etc/histograph/data   # Directory where API stores data files.
  admin:
    name: histograph              # Default Histograph user, is created
    password: passw🚜rd           # when starting API the first time.

neo4j:
  user: neo4j                     # Neo4j authentication (leave empty when
  password: password              # running Neo4j without authentication)

import:
  dirs:
    - ../data                     # List of directories containing Histograph
    - ...                         # datasets - used by import tool
```

Please see the [histograph-config](https://github.com/histograph/config) repository on GitHub to see the default options specified by `histograph.default.yml`.

### Core

Histograph Core reads messages from Redis, and syncs Neo4j and Elasticsearch.

    git clone https://github.com/histograph/core.git
    cd core
    npm install
    node index.js

You can specify the location of your configuration file by specifying its location using the `--config` argument, or by setting the `HISTOGRAPH_CONFIG` environment variable.

### API

Histograph API exposes a search API, as well as an API to upload and download datasets. The search API reads from Elasticsearch and Neo4j; the dataset API allows users to upload datasets, reads NDJSON files and writes messages to the Redis queue.

    git clone https://github.com/histograph/api.git
    cd api
    npm install
    node index.js

API can also be started with the `--config` command line argument.

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

With [histograph-import](https://github.com/histograph/import) you can upload local Histograph datasets to a remote (or local) instance of Histograph API. The import tool looks inside all directories specified by `config.import.dirs`. Datasets must follow the Histograph dataset naming convention:

- One dataset per directory;
- Each directory contains must contain a dataset JSON file, and a PITs or relations NDJSON file (or both):
  - `dataset1/dataset1.dataset.json`
  - `dataset1/dataset1.pits.ndjson`
  - `dataset1/dataset1.relations.ndjson`

For example, the GeoNames dataset looks like this:

  - `geonames/geonames.dataset.json`
  - `geonames/geonames.pits.ndjson`
  - `geonames/geonames.relations.ndjson`

To download and run histograph-import, do the following:

    git clone https://github.com/histograph/import.git
    cd import
    npm install
    node index.js tgn geonames ...

Without specifying one or more datasets as command line arguments, running `node indes.js` will import _all_ available datasets.

## Custom ontology and schemas

By default, the [`histograph-schemas`](https://github.com/histograph/schemas) module (and it's [RDF ontology](https://github.com/histograph/schemas/blob/master/ontology/histograph.ttl)) is used to generate the JSON schemas and Graphmalizer configuration files needed by Histograph.

You can create your own ontology and specify your own PIT types and relations, by cloning the histograph-schemas repository:

    git clone https://github.com/histograph/schemas
    cd schemas
    npm install

The most important file in this repository is `histograph.ttl`, the Histograph ontology. This file contains all types and relations used by Histograph Core, API and import scripts. You can edit the ontology and add your own types and relations, and run `node schemas-from-ontology.js` afterwards to create JSON schemas from the changed ontology. Finally, you will need to specify the absolute path to the `index.js` file in the cloned repository in your user configuration YAML file:

```yml
schemas:
  module: path/to/custom-schemas-repository/index.js
```