#!/bin/bash

mkdir -p /home/ubuntu/.kube
kind get kubeconfig --name="test-cluster" > /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config
