#!/bin/bash
HOME="/home/ubuntu"
echo $HOME
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common python-swiftclient
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee -a /etc/apt/sources.list.d/docker-ce.list
sudo apt-get update -y
sudo apt-get install -y docker-ce
sudo systemctl start docker
sudo systemctl enable docker
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni
sudo kubeadm init
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
echo "sudo chown $(id -u):$(id -g) $HOME/.kube/config"
#sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo chown 1000:1000 $HOME/.kube/config
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
#echo "sleep 5m to wait container services all up and running"
#sleep 5m
kubectl get nodes
kubectl get pods --all-namespaces
sleep 5s
echo "checking master is ready or not"
until [ $(kubectl get nodes | grep NotReady -ci) == 0 ];do echo "k8s master node is Not Ready then Sleep 5s .. " && sleep 5s; done
kubectl get nodes
kubectl get pods --all-namespaces
echo "checking containers are still creating or not"
until [ $(kubectl get pods --all-namespaces | grep ContainerCreating -ci) == 0 ];do echo "Some containers are still creating let's Sleep 5s .. " && sleep 5s; done
kubectl get pods --all-namespaces
echo "checking containers are pending creation or not"
until [ $(kubectl get pods --all-namespaces | grep Pending -ci) == 0 ];do echo "Some containers are still Pending let's Sleep 5s .. " && sleep 5s; done
kubectl get pods --all-namespaces
sleep 5s
echo "checking container image pulling error or not"
until [ $(kubectl get pods --all-namespaces | grep ErrImagePull -ci) == 0 ];do echo "Some containers are having ErrImagePull let's Sleep 5s .. " && sleep 5s; done
kubectl get pods --all-namespaces
echo "setup helm now..."
wget https://kubernetes-helm.storage.googleapis.com/helm-v2.8.0-linux-amd64.tar.gz
tar -zxvf helm-v2.8.0-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
helm help
helm init
sleep 30s
until [ $(kubectl get pods --namespace kube-system | grep tiller-deploy | grep Running -ci) == 1 ];do echo "Before patch, Tiller-Deploy Containers Not Ready then Sleep 5s .. " && sleep 5s; done
kubectl get pods --namespace kube-system
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
until [ $(kubectl get pods --namespace kube-system | grep tiller-deploy | grep Running -ci) == 1 ];do echo "After patch, Tiller-Deploy Containers Not Ready then Sleep 5s .. " && sleep 5s; done
kubectl get pods --namespace kube-system
helm create mychart
helm install --debug --dry-run ./mychart
echo "Congradulation your helm, k8s and docker dev box is ready !!!"
