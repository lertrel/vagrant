# vagrant
## Some useful Vagrantfile(s)

### 1. AWS-CLI Box

For setting a new box with AWS CLI

Please follow these steps
1. Make sure of having Virtualbox installed
2. Make sure of having Vagrant installed
3. Clone the current git repository
4. cd vagrant/aws
5. Copy an AWS credentials file (.csv) and place it into vagrant/aws, and rename the file to 'credentials.csv'
6. Still inside vagrant/aws, running command 'vagrant up'
7. After the execution is complete, you can login to the created VM with command 'vagrant ssh'
8. Testing if aws-cli is working by running command 'aws --version'
9. If aws-cli command auto-completion is not working then running command 'complete -C /usr/local/bin/aws_completer aws'
10. Test it by running command 'aws iam list-users --profile <<YOUR IAM USER>>'
  
Here are examples for **Linux or Gitbash**
```
cd vagrant/aws
cp <PATH TO YOUR AWS CREDENTIALS FILE> vagrant/aws/credentials.csv
vagrant up

...
Wait patiently 
(it could be over 15 minutes, depending on cpu/network)
...

vagrant ssh
$ aws --version
$ complete -C /usr/local/bin/aws_completer aws
$ aws iam list-users --profile <YOUR IAM USER>

```

### 2. Multi-servers Template

A builing block for creating multi-servers platform using Vagrant. 
This approach is different from a single Vagrantfile approach suggested in Vagrant website, 
but rather using a provided main Vagrantfile to load number of separated sub Vagrantfile(s)

Please follow these steps
1. Make sure of having Virtualbox installed
2. Make sure of having Vagrant installed
3. Clone the current git repository
4. cd vagrant/multi-servers

**If you want to try example, follow the below steps**

5. vagrant up --no-parallel
6. You will be asked "Running ansible playbooks? [y/n]:
7. The answer should be 'n', then 3 new VMs (lb1, web1, web2) will be created
8. execute vagrant up --no-parallel (for the second time)
9. You will be asked "Running ansible playbooks? [y/n]: (again)
10. But this time answer 'y', then a new VM ansible-controller1 will be created
11. Example ansible playbooks will be executed on host ansible-controller1

Here are examples for **Linux or Gitbash**
```
cd vagrant/multi-servers
vagrant up --no-parallel
It's running from directory - <WORKING DIR>/vagrant/multi-servers
nodesDir = <WORKING DIR>/vagrant/multi-servers/provisioning/nodes ------------------------------------------------
The following Ansible playbooks are found:
Play book --> provisioning/lbs/playbooks/1-lb1-prep.yml
Play book --> provisioning/webs/playbooks/2-all-webs-prep.yml
Play book --> provisioning/lbs/playbooks/3-lb1-proxy.yml
Running ansible playbooks? [y/n]: n

...
Wait patiently 
(it could be over 15 minutes, depending on cpu/network)
...

vagrant up --no-parallel
It's running from directory - <WORKING DIR>/vagrant/multi-servers
nodesDir = <WORKING DIR>/vagrant/multi-servers/provisioning/nodes ------------------------------------------------
The following Ansible playbooks are found:
Play book --> provisioning/lbs/playbooks/1-lb1-prep.yml
Play book --> provisioning/webs/playbooks/2-all-webs-prep.yml
Play book --> provisioning/lbs/playbooks/3-lb1-proxy.yml
Running ansible playbooks? [y/n]: y

...
Wait patiently 
(it could be over 15 minutes, depending on cpu/network)
...

curl http://172.17.10.12/
<html><header><title>Welcome to Server 1</title></header><body><H1>Hello from Server1</H1></body></html>"
curl http://172.17.10.12/
<html><header><title>Welcome to Server 2</title></header><body><H1>Hello from Server1</H1></body></html>"

```

**Well, what's just happened**

- The example here is another version of a basic vagrant/ansible tutorial found on internet
- Basically, using vagrant to create 3 servers lb1 (loadbalancer), web1 & web 2 (webservers nodes)
- Then, creating another server (ansible-controller1) for running ansible playbooks to configure each server
- After complete all ansible-playbooks, lb1 will be acted as a loanbalancer for web1 & web2
- Any http request to lb1 (http://172.17.10.12/) will be re-routed to web1 & web2 alternatively 

**Setting your own servers**

Following the above examples, setting your own multi-servers platform can be done in quite similar way (see below)

12. If you run the above example, please complete steps 13 & 14 ...
13. Halt the example VMs using vagrant halt
14. Destroy the example VMs using vagrant destroy
15. Make sure your are still in folder "vagrant/multi-servers", then remove all files and folders __under__ folder "provision/nodes"
16. Under folder "provision/nodes" Create a new folder for each sub Vagrantfile Ex. "provision/nodes/docker1/Vagrantfile", "provision/nodes/db1/Vagrantfile", etc.
17. Instead of standard Vagrantfile syntax, each Vagrantfile will be required to add some specific variants as below:

```

config = MultiServer.get_parent_vagrant_config
context = MultiServer.get_context
...

config.vm.define "..." do |node|

  node.vm.provider "virtualbox" do |vb, override|

    node.vm.box = "..."
    override.vm.network "private_network", ip: "..."
    override.vm.hostname = "..."
    vb.name = "..."
    vb.memory = "..."
    vb.cpus = 1
    
    ...

  end

  MultiServer.register_vm_ip("...", "...")

end

```

**Tips**
