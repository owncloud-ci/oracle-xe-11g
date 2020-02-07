# oracle-xe-11g

[![Build Status](https://drone.owncloud.com/api/badges/owncloud-ci/oracle-xe-11g/status.svg)](https://drone.owncloud.com/owncloud-ci/oracle-xe-11g)

Oracle Express Edition 11g Release 2 on Ubuntu 14.04.1 LTS - including a database for ownCloud CI.

## Usage
```Shell
docker pull deepdiver/docker-oracle-xe-11g
```

Run with 22 and 1521 ports opened:
```Shell
docker run -d -p 49160:22 -p 49161:1521 deepdiver/docker-oracle-xe-11g
```

Connect database with following setting:
```Shell
hostname: localhost
port: 49161
sid: xe
username: system
password: oracle
```

Password for SYS & SYSTEM
```Shell
oracle
```

Login by SSH
```Shell
ssh root@localhost -p 49160
password: admin
```

Connect to ownCloud CI database
```Shell
username: autotest
password: owncloud
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Maintainers

[Robert Kaussow](https://github.com/xoxys/)
