#!/usr/bin/env bash

if [[ "$1" == "docker" ]]; then
    # Download Peer-finder
    # ref: peer-finder: https://github.com/kubernetes/contrib/tree/master/peer-finder
    # wget peer-finder: https://github.com/kubernetes/charts/blob/master/stable/mongodb-replicaset/install/Dockerfile#L18
    wget -qO peer-finder https://github.com/kmodules/peer-finder/releases/download/v1.0.1-ac/peer-finder
    chmod +x peer-finder
    mv peer-finder hack/docker/mysql/5.7.25/peer-finder
    docker build -t alittleprogramming/mysql:group-test1 hack/docker/mysql/5.7.25/
#    docker push alittleprogramming/mysql:group-test1
    docker save alittleprogramming/mysql:group-test1 | pv | (eval $(minikube docker-env) && docker load)
fi


kubectl delete -f hack/docker/mysql/5.7.25/my.yaml;
kubectl get --all-namespaces pvc | grep my-gal | awk '{print $2 " -n " $1}' | xargs kubectl delete pvc;
kubectl get --all-namespaces pv | grep my-galera | awk '{print $1}' | xargs kubectl delete pv;
kubectl apply -f hack/docker/mysql/5.7.25/my.yaml