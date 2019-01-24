Vagrant.configure(2) do |config|
  config.vm.define "helm" do |helm|
    helm.vm.box = "ubuntu/xenial64"
    helm.vm.box_version = "20171011.0.0"
    helm.ssh.insert_key = 'false'
    helm.vm.hostname = "helm.swiftstack.org"
    helm.vm.network "private_network", ip: "192.168.22.200"
    helm.vm.provider :virtualbox do |vb|
        vb.memory = 6164
        vb.cpus = 4
    helm.vm.provision "shell", path: "helm.sh"
    helm.vm.synced_folder "git/", "/home/vagrant/git", create: true
    end
  end
end
