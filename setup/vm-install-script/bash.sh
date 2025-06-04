#!/bin/bash

echo "---- Starting DevSecOps Setup ----"

# Enhance prompt and enable color
echo "force_color_prompt=yes" | tee -a ~/.bashrc
echo "PS1='\\[\\e[01;36m\\]\\u\\[\\e[01;37m\\]@\\[\\e[01;33m\\]\\H\\[\\e[01;37m\\]:\\[\\e[01;32m\\]\\w\\[\\e[01;37m\\]\\$\\[\\033[0;37m\\] '" >> ~/.bashrc
source ~/.bashrc

# Essential updates and tools
apt-get update -y
systemctl daemon-reload
apt-get install -y curl gnupg2 lsb-release ca-certificates apt-transport-https software-properties-common jq build-essential vim python3-pip

# Install Docker
echo "[+] Installing Docker"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker && systemctl start docker

# Configure Docker for Kubernetes
mkdir -p /etc/docker
cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "storage-driver": "overlay2"
}
EOF
systemctl daemon-reload
systemctl restart docker

# Install Kubernetes components
echo "[+] Installing Kubernetes"
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes.gpg
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt-get update
KUBE_VERSION="1.24.17"
apt-get install -y kubelet=${KUBE_VERSION}-00 kubectl=${KUBE_VERSION}-00 kubeadm=${KUBE_VERSION}-00
apt-mark hold kubelet kubeadm kubectl

# Optional: Display VM UUID (useful for cloud VMs)
pip3 install jc
apt install -y dmidecode
jc dmidecode | jq .[1].values.uuid -r || true

# Init Kubernetes cluster (skip if <2 vCPU)
kubeadm reset -f
kubeadm init --kubernetes-version=${KUBE_VERSION} --skip-token-print

mkdir -p ~/.kube
cp /etc/kubernetes/admin.conf ~/.kube/config

# Apply Weave Net CNI
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
sleep 60

# Remove taints so single-node cluster can schedule pods
kubectl taint nodes --all node-role.kubernetes.io/master- || true
kubectl taint nodes --all node.kubernetes.io/not-ready- || true
kubectl get nodes -o wide

# Install Java 17 and Maven
echo "[+] Installing Java & Maven"
apt-get install -y openjdk-17-jdk maven
java -version && mvn -v

# Install Jenkins
echo "[+] Installing Jenkins"
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/jenkins.gpg
echo "deb https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
apt-get update
apt-get install -y jenkins
systemctl enable jenkins
systemctl start jenkins

# Add Jenkins to Docker group
usermod -aG docker jenkins
echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo "---- DevSecOps Environment Ready ----"

