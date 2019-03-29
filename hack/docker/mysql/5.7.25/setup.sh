#!/usr/bin/env bash

apt-get update
apt-get install nano
nano /etc/mysql/my.cnf
----------------
[mysqld]

# General replication settings
gtid_mode = ON
enforce_gtid_consistency = ON
master_info_repository = TABLE
relay_log_info_repository = TABLE
binlog_checksum = NONE
log_slave_updates = ON
log_bin = binlog
binlog_format = ROW
transaction_write_set_extraction = XXHASH64
loose-group_replication_bootstrap_group = OFF
loose-group_replication_start_on_boot = OFF
loose-group_replication_ssl_mode = REQUIRED
loose-group_replication_recovery_use_ssl = 1

# Shared replication group configuration
loose-group_replication_group_name = "67e110ec-d3d7-4cb8-a192-13ddad17dcc7"
loose-group_replication_ip_whitelist = "172.17.0.3,172.17.0.4,172.17.0.6,172.17.0.8,172.17.0.9,172.17.0.10"
loose-group_replication_group_seeds = "172.17.0.3:33060,172.17.0.4:33060,172.17.0.6:33060,172.17.0.8:33060,172.17.0.9:33060,172.17.0.10:33060"

# Single or Multi-primary mode? Uncomment these two lines
# for multi-primary mode, where any host can accept writes
#loose-group_replication_single_primary_mode = OFF
#loose-group_replication_enforce_update_everywhere_checks = ON

# Host specific replication configuration
server_id = 1
bind-address = "172.17.0.3"
report_host = "172.17.0.3"
loose-group_replication_local_address = "172.17.0.3:33060"
---------------
[mysqld]

# General replication settings
gtid_mode = ON
enforce_gtid_consistency = ON
master_info_repository = TABLE
relay_log_info_repository = TABLE
binlog_checksum = NONE
log_slave_updates = ON
log_bin = binlog
binlog_format = ROW
transaction_write_set_extraction = XXHASH64
loose-group_replication_bootstrap_group = OFF
loose-group_replication_start_on_boot = OFF
loose-group_replication_ssl_mode = REQUIRED
loose-group_replication_recovery_use_ssl = 1

# Shared replication group configuration
loose-group_replication_group_name = "67e110ec-d3d7-4cb8-a192-13ddad17dcc7"
loose-group_replication_ip_whitelist = "my-galera-0.kubedb-gvr.demo.svc,my-galera-1.kubedb-gvr.demo.svc,my-galera-2.kubedb-gvr.demo.svc"
loose-group_replication_group_seeds = "my-galera-0.kubedb-gvr.demo.svc:33060,my-galera-1.kubedb-gvr.demo.svc:33060,my-galera-2.kubedb-gvr.demo.svc:33060"

# Single or Multi-primary mode? Uncomment these two lines
# for multi-primary mode, where any host can accept writes
#loose-group_replication_single_primary_mode = OFF
#loose-group_replication_enforce_update_everywhere_checks = ON

# Host specific replication configuration
server_id = 1
bind-address = "my-galera-0.kubedb-gvr.demo.svc"
report_host = "my-galera-0.kubedb-gvr.demo.svc"
loose-group_replication_local_address = "my-galera-0.kubedb-gvr.demo.svc:33060"
---------------

/etc/init.d/mysql restart mysql

mysql -u root --password=uWuj7-dbvefZVnJx
# mysql>
SET SQL_LOG_BIN=0;
CREATE USER 'repl'@'%' IDENTIFIED BY 'password' REQUIRE SSL;
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
# -> from here
SET SQL_LOG_BIN=1;

CHANGE MASTER TO MASTER_USER='repl', MASTER_PASSWORD='password' FOR CHANNEL 'group_replication_recovery';
INSTALL PLUGIN group_replication SONAME 'group_replication.so';
SHOW PLUGINS;

# if no group exists, then for the 1st member
SET GLOBAL group_replication_bootstrap_group=ON;
START GROUP_REPLICATION;
SET GLOBAL group_replication_bootstrap_group=OFF;
# check that the 1st member is up
SELECT * FROM performance_schema.replication_group_members;

# for the 2nd member
START GROUP_REPLICATION;
# check the membership
SELECT * FROM performance_schema.replication_group_members;
# for the 3rd member
START GROUP_REPLICATION;
# check the membership
SELECT * FROM performance_schema.replication_group_members;

#server_id=1
#gtid_mode=ON
#enforce_gtid_consistency=ON
#binlog_checksum=NONE
#
#log_bin=binlog
#log_slave_updates=ON
#binlog_format=ROW
#master_info_repository=TABLE
#relay_log_info_repository=TABLE
#
#transaction_write_set_extraction=XXHASH64
#group_replication_group_name="6eba98a3-b349-43f7-bd77-c32d97a72edb"
#group_replication_start_on_boot=off
#group_replication_local_address= "172.17.0.16:33060"
#group_replication_group_seeds= "172.17.0.16:33060,172.17.0.17:33060,172.17.0.18:33060"
#group_replication_bootstrap_group=off
