pubkey=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt \
    | openssl rsa -pubin -outform der 2>/dev/null \
    | openssl dgst -sha256 -hex \
    | sed 's/^.* //')

if [ -z "$pubkey" ]; then
	echo "No public key exists!"
	exit 1
fi

token=$(kubeadm token list | grep -v TOKEN | grep default-node-token | head -1 | cut -f1 -d' ')
if [ -z "$token" ]; then
	echo "No token exists, create it now..."
	kubeadm token create --print-join-command
	token=$(kubeadm token list | grep -v TOKEN | grep default-node-token | head -1 | cut -f1 -d' ')
	if [ -z "$token" ]; then
		echo "Token creation failed!"
		exit 1
	fi
fi

IP=$(kubectl get nodes -lnode-role.kubernetes.io/master -ojsonpath='{..addresses[?(@.type=="InternalIP")].address}')
if [ -z "$IP" ]; then
  echo "Cannot get master ip"
  exit 1
fi

PORT=6443


echo "kubeadm join $IP:$PORT --token $token --discovery-token-ca-cert-hash sha256:$pubkey"
