# oracle-xe

[![Build Status](https://img.shields.io/drone/build/owncloud-ci/oracle-xe?logo=drone&server=https%3A%2F%2Fdrone.owncloud.com)](https://drone.owncloud.com/owncloud-ci/oracle-xe)
[![Docker Hub](https://img.shields.io/docker/v/owncloudci/oracle-xe?logo=docker&label=dockerhub&sort=semver&logoColor=white)](https://hub.docker.com/r/owncloudci/oracle-xe)
[![GitHub contributors](https://img.shields.io/github/contributors/owncloud-ci/oracle-xe)](https://github.com/owncloud-ci/oracle-xe/graphs/contributors)
[![Source: GitHub](https://img.shields.io/badge/source-github-blue.svg?logo=github&logoColor=white)](https://github.com/owncloud-ci/oracle-xe)
[![License: MIT](https://img.shields.io/github/license/owncloud-ci/oracle-xe)](https://github.com/owncloud-ci/oracle-xe/blob/master/LICENSE)

Oracle Express Edition on Ubuntu - including a database for ownCloud CI.

## Usage

```console
docker pull owncloudci/oracle-xe
```

Run with 22 and 1521 ports opened:

```console
docker run -d -p 49160:22 -p 49161:1521 owncloudci/oracle-xe
```

Connect database with following setting:

```console
hostname: localhost
port: 49161
sid: xe
username: system
password: oracle
```

Password for SYS & SYSTEM:

```console
oracle
```

Login by SSH:

```console
ssh root@localhost -p 49160
password: admin
```

Connect to ownCloud CI database:

```console
username: autotest
password: owncloud
```

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/owncloud-ci/oracle-xe/blob/master/LICENSE) file for details.

## Copyright

```Text
Copyright (c) 2022 ownCloud GmbH
```
