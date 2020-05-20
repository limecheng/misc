# ------ 
# Purpose: Vagrantfile to generate 3 Ubuntu VMs for testing purpose
# Changelog:
#   2020-Feb-12: bunmp up OS from 1604 to 18.04
# ------

IMAGE_NAME = "bento/ubuntu-18.04"
N = 2

$script = <<-'SCRIPT'
sudo useradd -m -d /home/ubuntu -s /bin/sh ubuntu
echo -e "password\npassword" | sudo passwd ubuntu
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq
sudo apt-get install git -y
SCRIPT

Vagrant.configure("2") do |config|

    config.vm.provision "shell", inline: $script
    config.ssh.insert_key = false
    config.vagrant.plugins = "vagrant-vbguest"

    config.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 2
    end
      
    config.vm.define "k8s-master" do |master|
        master.vm.box = IMAGE_NAME
        master.vm.network "private_network", ip: "192.168.50.10"
        master.vm.hostname = "master"
    end

    (1..N).each do |i|
        config.vm.define "node-#{i}" do |node|
            node.vm.box = IMAGE_NAME
            node.vm.network "private_network", ip: "192.168.50.#{i + 10}"
            node.vm.hostname = "node-#{i}"
        end
    end
end
