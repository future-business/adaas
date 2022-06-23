#!/bin/sh
set -e

curl https://install.citusdata.com/community/rpm.sh | sudo bash

yum install -y citus110_13

yum install -y postgresql13-contrib
yum install -y postgis30_13 pgrouting_13
yum install -y timescaledb_13

postgresql-13-setup initdb

systemctl enable postgresql-13
systemctl start postgresql-13

## 修改postgresql.conf/修改监听配置： - /var/lib/pgsql/13/data/postgresql.conf
listen_addresses = '*'

## 修改pg_hba.conf/添加内容如下： - /var/lib/pgsql/13/data/pg_hba.conf
host    all             all             192.168.169.0/24        trust
host    all             all             127.0.0.1/32            trust
host    all             all             ::1/128                 trust

## 创建并配置数据库
su postgres
psql
create database test;
\c test;
create extension citus;

SELECT * FROM citus_get_active_worker_nodes();

SELECT * from citus_add_node('192.168.169.217', 5432);
SELECT * from citus_add_node('192.168.169.218', 5432);
SELECT * from citus_add_node('192.168.169.219', 5432);
SELECT * from citus_add_node('192.168.169.103', 5432);

## 设置副本因子
alter system set citus.shard_replication_factor=2;
select pg_reload_conf();

## 查看副本因子
show citus.shard_replication_factor;

## 查看工作节点
SELECT * FROM master_get_active_worker_nodes();

## 查看分片
select * from citus_shards;

## 重新平分片
select rebalance_table_shards();

## 查看表的分片分布
select
shard.logicalrelid as table,
placement.shardid as shard,
node.nodename as host
from
pg_dist_placement placement,
pg_dist_node node,
pg_dist_shard shard
where placement.groupid = node.groupid and shard.shardid = placement.shardid
order by shard;