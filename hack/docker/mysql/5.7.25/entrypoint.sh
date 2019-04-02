#!/usr/bin/env bash

set -eoux pipefail

function timestamp() {
    date +"%Y-%m-%d %T"
}

# wait_for_each_instance_be_ready( group_size, base_name, gov_svc, ns)
# gr_size   = size of the replication group
# base_name = the name of MySQL CRD object
# gov_svc   = the governing service for the StatefulSet (representing the group)
# ns        = the namespace
function wait_for_each_instance_be_ready() {
    local gr_size=$1
    local base_name=$2
    local gov_svc=$3
    local ns=$4

    while true; do
        ready=0
        for ((i=0;i<$gr_size;i++)); do
            out=`hostname`
#            out=`kubectl exec -it -n $ns $base_name-$i -c mysql -- hostname`
            if [[ "$out" = "" ]]; then
                ready=1
                break
            fi
        done

        if [[ $ready = 0 ]]; then
            break
        fi
    done

    echo "$(timestamp) [INFO] All servers are ready :)"
}

# get_ip_whitelist( group_size, base_name, gov_svc, ns)
# gr_size   = size of the group
# base_name = the name of MySQL CRD object
# gov_svc   = the governing service for the StatefulSet (representing the group)
# ns        = the namespace
function get_ip_whitelist() {
    local gr_size=$1
    local base_name=$2
    local gov_svc=$3
    local ns=$4

    for ((i=0;i<$gr_size;i++)); do
        if (("$i" > "0")); then
            echo -n ",";
        fi
        echo -n "$base_name-$i.$gov_svc.$ns.svc"
    done
}

# ==============
# export GROUP_SIZE=5; export BASE_NAME=my-galera; export GOV_SVC=kubedb-gvr; export NAMESPACE=demo
# ==============

echo "GROUP_SIZE=$GROUP_SIZE"
echo "BASE_NAME=$BASE_NAME"
echo "GOV_SVC=$GOV_SVC"
echo "NAMESPACE=$NAMESPACE"
echo "GROUP_NAME=$GROUP_NAME"
echo ""

wait_for_each_instance_be_ready ${GROUP_SIZE} ${BASE_NAME} ${GOV_SVC} ${NAMESPACE}

export hosts=`get_ip_whitelist ${GROUP_SIZE} ${BASE_NAME} ${GOV_SVC} ${NAMESPACE}`
echo ">>>>>> ips: $hosts"
export seeds=`echo -n ${hosts} | sed -e "s/,/:33060,/g" && echo -n ":33060"`
echo ">>>>>> seeds: $seeds"
declare -i srv_id=`hostname | sed -e "s/${BASE_NAME}-//g"`
((srv_id+=1))
echo ">>>>>> srv_id: $srv_id"
export cur_host=`echo -n "$(hostname).${GOV_SVC}.${NAMESPACE}.svc"`
echo ">>>>>> cur_host: $cur_host"
export cur_addr="${cur_host}:33060"
echo ">>>>>> cur_addr: $cur_addr"



#echo "hi" > tmp.cnf
#cat >> tmp.cnf <<EOL
##loose-group_replication_ip_whitelist = "${hosts}"
##loose-group_replication_group_seeds = "$seeds"
##server_id = ${srv_id}
##bind-address = "${cur_host}"
##report_host = "${cur_host}"
##loose-group_replication_local_address = "${cur_addr}"
#EOL
#cat tmp.cnf

# -----------------
## group replication pre-requisites & recommendations
#binlog-format = ROW
#gtid-mode = ON
#enforce-gtid-consistency = ON
#log-slave-updates = ON
#master-info-repository = TABLE
#relay-log-info-repository = TABLE
#binlog-checksum = NONE
#slave-preserve-commit-order = ON
## prevent use of non-transactional storage engines
#disabled_storage_engines="MyISAM,BLACKHOLE,FEDERATED,ARCHIVE"
## InnoDB gap locks are problematic for multi-primary conflict detection; none are used with READ-COMMITTED
## So if you don't rely on REPEATABLE-READ semantics and/or wish to use multi-primary mode then this
## isolation level is recommended
#transaction-isolation = 'READ-COMMITTED'
## Let Group Replication manage the READ/WRITE mode of the server entirely throughout the process lifecycle
## super_read_only = ON
#
## group replication specific options
#transaction-write-set-extraction = XXHASH64
## disable the IP whitelisting, as we won't know what the IP range will be
#loose-group-replication-ip-whitelist='0.0.0.0/0'
#
## dynamic options to be driven by command-line parameters
##****************************************************************************
## server-id = ??? # must be unique within replication topologies
## group_replication_group_name = ??? # must be valid UUID
## group_replication_bootstrap_group = ??? # must be ON for the first node in the group
## group_replication_local_address = ??? # needs to be an IP address / hostname which the other GR containers can reach
## group_replication_group_seeds = ??? # is necessary for the non-bootstrap nodes
##****************************************************************************
# -----------------


echo "/etc/mysql/my.cnf contents are as follows:"
cat >> /etc/mysql/my.cnf <<EOL

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
loose-group_replication_group_name = "${GROUP_NAME}"
loose-group_replication_ip_whitelist = "${hosts}"
loose-group_replication_group_seeds = "${seeds}"

# Single or Multi-primary mode? Uncomment these two lines
# for multi-primary mode, where any host can accept writes
#loose-group_replication_single_primary_mode = OFF
#loose-group_replication_enforce_update_everywhere_checks = ON

# Host specific replication configuration
server_id = ${srv_id}
bind-address = "${cur_host}"
report_host = "${cur_host}"
loose-group_replication_local_address = "${cur_addr}"
EOL

# TODO: remove this
echo ""
cat /etc/mysql/my.cnf
echo ""

while true; do
#    echo .
    sleep 1
done

#echo "$(timestamp) [INFO] Starting mysql server..."
#docker-entrypoint.sh mysqld >/dev/null 2>&1 &
#pid=$!
#echo "$(timestamp) [INFO] Waiting for the server being run..."
##sleep 30
#while true; do
#    echo ">>>>>>>>>> pining..."
#    out=`mysqladmin -u root --password=uWuj7-dbvefZVnJx ping 2> /dev/null || true`
#    echo ">>>>>>>> out:$out"
#    if [[ "$out" == "mysqld is alive" ]]; then
#        sleep 5
#        break
#    fi
#    sleep 1
#done
#
##while true; do
##    echo .
##    sleep 1
##done
#
#echo "$(timestamp) [INFO] Initialing the server..."
#export mysql_header="mysql -u root --password=uWuj7-dbvefZVnJx"
#out=`${mysql_header} -N -e "select count(host) from mysql.user where mysql.user.user='repl';" 2> /dev/null | awk '{print$1}'`
#if [[ "$out" -eq "0" ]]; then
#    ${mysql_header} -N -e "SET SQL_LOG_BIN=0;" 2> /dev/null
#    ${mysql_header} -N -e "CREATE USER 'repl'@'%' IDENTIFIED BY 'password' REQUIRE SSL;" 2> /dev/null
#    ${mysql_header} -N -e "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';" 2> /dev/null
#    ${mysql_header} -N -e "FLUSH PRIVILEGES;" 2> /dev/null
#    ${mysql_header} -N -e "SET SQL_LOG_BIN=1;" 2> /dev/null
#
#    echo ">>>> plugins are as follows:"
#    out=`${mysql_header} -N -e "SHOW PLUGINS;" 2> /dev/null || true`
#    echo ">>>> plugins= $out"
#fi
##mysql -u root --password=uWuj7-dbvefZVnJx
### mysql>
##SET SQL_LOG_BIN=0;
##CREATE USER 'repl'@'%' IDENTIFIED BY 'password' REQUIRE SSL;
##GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
##FLUSH PRIVILEGES;
### -> from here
##SET SQL_LOG_BIN=1;
#
#${mysql_header} -N -e "CHANGE MASTER TO MASTER_USER='repl', MASTER_PASSWORD='password' FOR CHANNEL 'group_replication_recovery';" 2> /dev/null
#out=`${mysql_header} -N -e 'SHOW PLUGINS;' 2> /dev/null | grep group_replication`
#if [[ -z "$out" ]]; then
#    ${mysql_header} -e "INSTALL PLUGIN group_replication SONAME 'group_replication.so';" 2> /dev/null
#fi
#
## TODO: it is optional. So remove this
#echo ">>>> plugins are as follows:"
#out=`${mysql_header} -N -e "SHOW PLUGINS;" 2> /dev/null || true`
#echo ">>>> plugins= $out"

function check() {
    local gr_size=$1
    local base_name=$2
    local gov_svc=$3
    local ns=$4

    # TODO: Need to handle for multiple group existence
    local member_hosts=( `echo -n ${hosts} | sed -e "s/,/ /g"` )

    group_found=0
    for host in ${member_hosts[@]}; do

        export mysql_header="mysql -u root --password=uWuj7-dbvefZVnJx --host=${host}"
        primary_id=${mysql_header} -N -e "SHOW STATUS LIKE '%primary%';" 2>/dev/null
        ${mysql_header} -N -e "SELECT MEMBER_PORT FROM performance_schema.replication_group_members;"
        ids=( `${mysql_header} -N -e "SELECT MEMBER_ID FROM performance_schema.replication_group_members WHERE MEMBER_STATE = 'ONLINE' OR MEMBER_STATE = 'RECOVERING';" 2>/dev/null` )

        for id in ${ids[@]}; do
            if [[ -n "${primary_id}" -a "${primary_id}" == "${id}" ]]; then
                group_found=1
            fi
        done
    done

    for ((i=0;i<$gr_size;i++)); do
        if (("$i" > "0")); then
            echo -n ",";
        fi
        echo -n "$base_name-$i.$gov_svc.$ns.svc"
    done
}