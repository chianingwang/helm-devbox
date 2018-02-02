Vagrant.configure(2) do |config|
  config.vm.define "helm" do |helm|
    helm.vm.box = "ubuntu/xenial64"
    helm.vm.box_version = "20171011.0.0"
    helm.ssh.insert_key = 'false'
    helm.vm.hostname = "helm.swiftstack.org"
    helm.vm.network "private_network", ip: "172.28.128.47", name: "vboxnet0"
    helm.vm.provider :virtualbox do |vb|
        vb.memory = 4096
        vb.cpus = 2
    helm.vm.provision "shell", path: "helm.sh"
    helm.vm.synced_folder "test/", "/home/vagrant/test"
    end
  end
end
