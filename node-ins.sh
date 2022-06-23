#!/bin/sh
set -e

curl https://install.citusdata.com/community/rpm.sh | sudo bash

yum install -y citus110_13

yum install -y postgresql13-contrib
yum install -y postgis30_13 pgrouting_13
yum install -y timescaledb_13

systemctl enable postgresql-13
systemctl start postgresql-13
