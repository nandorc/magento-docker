# Magento Dockerizer

> **Version:** 0.1.0

Project to deploy a Magento Open Source project locally using Docker Containers

## Getting started

```bash
#!/bin/bash

# Setup mage alias
bash ./bin/setup
```

## Devenlopment Environment Components Versions

- Adobe Commerce CE (Magento) v2.4.5
- Apache v2.4.x
- PHP v8.1.x
- Composer v2.x
- Elasticsearch : [v7.17.8](https://www.elastic.co/guide/en/elasticsearch/reference/7.17/docker.html)

## Using `mage` utility

```bash
#!/bin/bash

# Start services
#   Additional args from docker compose up are received
mage up

# Dispose services
mage down

# Restart services
mage restart

# Connect to web server terminal
mage bash

# Run composer command at magento-app directory
mage composer
```

Any command executed using `mage` command is done through `docker compose exec` command using `magento` user.
