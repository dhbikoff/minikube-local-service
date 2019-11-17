#!/usr/bin/env bash

function USAGE {
  echo "Basic usage: ./deploy.sh -n myservice -h myhost.dev"
  echo "Flags:"
  echo "-h Ingress host"
  echo "-n Name for your helm package and url path part behind your ingress host - Default: \"default\""
  echo "-p Target service host port - Default: 3000"
  echo "-d Delete previously created helm package name, ex. ./deploy.sh -d default"
  echo "Example: ./deploy.sh -n myservice -h myhost.dev -p 3001"
  exit 1
}

PACKAGE_SUFFIX="-localservice"
NAME="default"
PORT=3000
INGRESS_HOST=

while getopts :d:h:n:p FLAG; do
  case $FLAG in
    d)
      DEL_PACKAGE="$OPTARG"
      ;;
    h)
      INGRESS_HOST="$OPTARG"
      ;;
    n)
      NAME="$OPTARG"
      ;;
    p)
      PORT="$OPTARG"
      ;;
    *)
      USAGE
      ;;
  esac
done

if [ ! -z $DEL_PACKAGE ]; then
  echo "Removing helm package ${DEL_PACKAGE}${PACKAGE_SUFFIX}"
  helm del --purge "${DEL_PACKAGE}${PACKAGE_SUFFIX}"
  exit $?
fi

if [ -z $INGRESS_HOST ]; then
  echo "Missing ingress host"
  USAGE
fi

VM_TO_HOST_IP=$(minikube ssh -- route -n | grep ^0.0.0.0 | awk '{ print $2 }' | xargs echo -n)
echo found host ip from within vm $VM_TO_HOST_IP
MINIKUBE_IP=$(minikube ip | xargs echo -n)
echo found minikube ip $MINIKUBE_IP

helm install --debug ./localservice -n "${NAME}${PACKAGE_SUFFIX}" \
  --set targetPort=$PORT \
  --set minikubeIp=$MINIKUBE_IP \
  --set pathPart=$NAME \
  --set vmToHostIp=$VM_TO_HOST_IP \
  --set ingressHost=$INGRESS_HOST
