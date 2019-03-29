#!/usr/bin/env bash

if [[ "$1" == "docker" ]]; then
    docker build -t alittleprogramming/mysql:group-test1 hack/docker/mysql/5.7.25/
#    docker push alittleprogramming/mysql:group-test1
    docker save alittleprogramming/mysql:group-test1 | pv | (eval $(minikube docker-env) && docker load)
fi


kubectl delete -f hack/docker/mysql/5.7.25/my.yaml;
kubectl get --all-namespaces pvc | grep my-gal | awk '{print $2 " -n " $1}' | xargs kubectl delete pvc;
kubectl get --all-namespaces pv | grep my-galera | awk '{print $1}' | xargs kubectl delete pv;
kubectl create -f hack/docker/mysql/5.7.25/my.yaml