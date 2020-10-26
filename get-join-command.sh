pubkey=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt \
    | openssl rsa -pubin -outform der 2>/dev/null \
    | openssl dgst -sha256 -hex \
    | sed 's/^.* //')


token=$(kubeadm token list | grep 'default boot' | cut -f1 -d' ')


echo "kubeadm join --token=$token --discovery-token-ca-cert-hash sh2256:$pubkey"
