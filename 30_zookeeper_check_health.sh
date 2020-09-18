#!/bin/sh
# 参数格式: "localhost1:2181#test1,localhost2:2181#test2,localhost3:2181#test3" 
# 即: host:port#note
# eg: ./30_zookeeper_check_health.sh "localhost1:2181#test1,localhost2:2181#test2,localhost3:2181#test3"
zk_list=(${1//,/ })
length=${#zk_list[@]}
zero=0
if test $[length] -eq $[zero]
then
    exit 0
fi
ts=`date +%s`;
metric="["
for e in ${zk_list[@]}
do
    zk=(${e//:/ })
    host=${zk[0]}
    port_and_note=(${zk[1]//#/ })
    port=${port_and_note[0]}   
    note=${port_and_note[1]}   
    status=`echo ruok | nc "$host $port" | grep imok | wc -l`
    m="{\"metric\": \"zookeeper.check.health\", \"endpoint\": \"$e\", \"timestamp\": $ts,\"step\": 30,\"value\": $status,\"counterType\": \"GAUGE\",\"tags\": \"note=$note\"},"
    metric=$metric$m
done
final=${metric: -1}
if [ "$final"x = ","x ]
then
    metric="${metric%?}]"
fi
echo $metric
