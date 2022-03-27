#!/bin/bash

apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
mkdir /etc/docker

cat <<EOF | tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

systemctl enable docker
systemctl daemon-reload
systemctl restart docker
apt-get update
apt-get install -y apt-transport-https ca-certificates curl

# swapoff -a
# sed -i 's/\/swap.img/#\/swap.img/g' /etc/fstab

curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

#Csak a masteren:
# kubeadm init --pod-network-cidr 10.244.0.0/16  --apiserver-advertise-address 192.168.0.
# export KUBECONFIG=/etc/kubernetes/admin.conf
# kubectl apply -f  https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# kubectl config set-context --current --namespace=hakap

#Új token:
# TOKEN=$(kubeadm token generate)
# kubeadm token create $TOKEN --print-join-command --ttl=0

#A workereken:
# kubeadm join 192.168.83.128:6443 --token snkzqx.pgvaoyle12qbqwah --discovery-token-ca-cert-hash sha256:837696cbce4c495c92281f66d53fa23b8a054df1d16236f099c732342e41f334

#Ha fos:
# kubeadm reset
# rm -r /etc/cni/net.d
# iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
