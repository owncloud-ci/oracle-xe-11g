# oracle-xe

[![Build Status](https://drone.owncloud.com/api/badges/owncloud-ci/oracle-xe/status.svg)](https://drone.owncloud.com/owncloud-ci/oracle-xe)

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

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
