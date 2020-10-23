mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
yum makecache
#systemctl disable firewalld
#systemctl stop firewalld
#setenforce 0
#vim /etc/sysconfig/selinux 
yum install -y vim
#set -o vi
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
       http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
EOF
sysctl -p /etc/sysctl.d/k8s.conf
yum-config-manager \
    --add-repo \
        https://download.docker.com/linux/centos/docker-ce.repo

yum install -y yum-utils

yum install -y docker-ce docker-ce-cli containerd.io

#docker --version
cat <<EOF > /etc/docker/daemon.json 
{
 "registry-mirrors": ["https://frz7i079.mirror.aliyuncs.com"]
}
EOF

systemctl status docker
systemctl enable docker
systemctl start docker
systemctl status docker

#yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

images_list=$(kubeadm config images list 2> /dev/null)
for name in $images_list; do
     echo ${name: 11};  
     imageName=${name: 11}
     docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
     docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
     docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
done
