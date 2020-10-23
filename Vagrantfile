IMAGE_NAME = "base-os-k8s"
K8S_NAME = "ditwl-k8s-01"
MASTERS_NUM = 1
MASTERS_CPU = 2 
MASTERS_MEM = 2048

NODES_NUM = 3
NODES_CPU = 1
NODES_MEM = 2048

IP_BASE = "192.168.50."

VAGRANT_DISABLE_VBOXSYMLINKCREATE=1

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false

    (1..MASTERS_NUM).each do |i|      
        config.vm.define "k8s-m-#{i}" do |master|
            master.vm.box = IMAGE_NAME
            master.vm.network "private_network", ip: "#{IP_BASE}#{i + 10}"
            master.vm.hostname = "k8s-m-#{i}"

            master.vm.provision "shell", inline: "rm -rf /vagrant/"

            master.vm.synced_folder  ".", "/vagrant", disabled: false

            master.vm.provider "virtualbox" do |v|
                v.name = master.vm.hostname
                v.memory = MASTERS_MEM
                v.cpus = MASTERS_CPU
            end
            master.vm.provision "ansible" do |ansible|
                ansible.playbook = "roles/k8s.yml"
                #Redefine defaults
                ansible.extra_vars = {
                    k8s_cluster_name:       K8S_NAME,
                    k8s_master_admin_user:  "vagrant",
                    k8s_master_admin_group: "vagrant",
                    k8s_master_apiserver_advertise_address: "#{IP_BASE}#{i + 10}",
                    k8s_master_node_name: "k8s-m-#{i}",
                    k8s_node_public_ip: "#{IP_BASE}#{i + 10}"
                }
            end
        end
    end

    (1..NODES_NUM).each do |j|
        config.vm.define "k8s-n-#{j}" do |node|
            node.vm.box = IMAGE_NAME
            node.vm.network "private_network", ip: "#{IP_BASE}#{j + 10 + MASTERS_NUM}"
            node.vm.hostname = "k8s-n-#{j}"
            node.vm.provision "shell", inline: "rm -rf /vagrant/"
            node.vm.synced_folder  ".", "/vagrant", disabled: false
            node.vm.provider "virtualbox" do |v|
                v.name = node.vm.hostname
                v.memory = NODES_MEM
                v.cpus = NODES_CPU
            end
            node.vm.provision "ansible" do |ansible|
                ansible.playbook = "roles/k8s.yml"                   
                #Redefine defaults
                ansible.extra_vars = {
                    k8s_cluster_name:     K8S_NAME,
                    k8s_node_admin_user:  "vagrant",
                    k8s_node_admin_group: "vagrant",
                    k8s_node_public_ip: "#{IP_BASE}#{j + 10 + MASTERS_NUM}"
                }
            end
        end
    end
end
