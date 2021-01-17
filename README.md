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
This approach is different from a single Vagrantfile approach suggested in Vagrant official website, 
but rather using a provided main Vagrantfile to load number of separated sub Vagrantfile(s)

Please follow these steps
1. Make sure of having Virtualbox installed
2. Make sure of having Vagrant installed
3. Clone the current git repository
4. cd vagrant/multi-servers

**If you want to try example, follow the below steps**

5. vagrant up --no-parallel
6. You will be asked "Running ansible playbooks? [y/n]:"
(The answer should be 'n' as we want all other VMs to created and ready 
before the ansible controller VM be created)
7. Then 3 new VMs (lb1, web1, web2) will be created
8. execute vagrant up --no-parallel (for the second time)
9. You will be asked "Running ansible playbooks? [y/n]: (again)
10. But this time answer 'y' to create ansible controller VM, then a new VM "ansible-controller1" will be created
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
- So why do we need a new VM for running ansible??? 
- If your local computer is running on Windows, ansible cannot be installed, so a linux VM is needed as ansible host
- Even if your local computer is running on linux or MacOS, having a disposable environment for running ansible will keep your local computer clean.
- Moreover, the solution is highly portable and can be redo from scratch anywhere.

**Setting your own servers**

Following the above examples, setting your own multi-servers platform can be done in quite similar way (see below)

12. If you run the above example, please complete steps 13 & 14 otherwise skip to step 15 ...
13. Halt the example VMs using 'vagrant halt'
14. Destroy the example VMs using 'vagrant destroy'
15. Make sure your are still in folder "vagrant/multi-servers", then remove all files and folders __under__ folder "provisioning/nodes"
16. Under folder "provisioning/nodes" creating a new folder for each of your sub Vagrantfile Ex. "provisioning/nodes/docker1/Vagrantfile", "provisioning/nodes/db1/Vagrantfile", etc.
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

18. If you wish to run ansible playbook(s), create folder playbook in the same folder of each sub vagrant file, and please ansible playbook(s) in there.
Ex. "provisioning/nodes/docker1/playbooks", "provisioning/nodes/db1/playbooks", etc.
19. By default, the playbooks will be executed unpredictably in the same order they were found in your filesystem
20. If some playbooks have to be executed in specific order, then place an interger in front of file name.
Ex. 
- "provisioning/nodes/docker1/playbooks/1-install-docker.yml"
- "provisioning/nodes/docker1/playbooks/4-deploy-services.yml"
- "provisioning/nodes/docker1/playbooks/5-link-services-to-db.yml"
- "provisioning/nodes/db1/playbooks/2-install-db.yml"
- "provisioning/nodes/db1/playbooks/3-load-data.yml"

In this case, the ansible playbooks (which have an interger in front of there names) will be executed first in ascending, and files without number will still be executed randomly.

- "provisioning/nodes/docker1/playbooks/1-install-docker.yml"
- "provisioning/nodes/db1/playbooks/2-install-db.yml"
- "provisioning/nodes/db1/playbooks/3-load-data.yml"
- "provisioning/nodes/docker1/playbooks/4-deploy-services.yml"
- "provisioning/nodes/docker1/playbooks/5-link-services-to-db.yml"

21. Finaally it's time for 'vagrant up --no-parallel'
22. You will be asked "Running ansible playbooks? [y/n]:"
(The answer should be 'n' as we want all other VMs to created and ready 
before the ansible controller VM be created)
23. Then your associated sub Vagrant files under the folder "provisioning/nodes" will be executed 1 by 1
24. When all done, then execute vagrant up --no-parallel (for the second time)
25. You will be asked "Running ansible playbooks? [y/n]: (again)
26. But this time answer 'y' to create ansible controller VM, then a new VM "ansible-controller1" will be created
27. All ansible playbooks will be executed on host ansible-controller1


Here are examples for **Linux or Gitbash**
```
cd vagrant/multi-servers
vagrant up --no-parallel
It's running from directory - <WORKING DIR>/vagrant/multi-servers
nodesDir = <WORKING DIR>/vagrant/multi-servers/provisioning/nodes ------------------------------------------------
The following Ansible playbooks are found:
...
Running ansible playbooks? [y/n]: n

...
Wait patiently 
(it could be over 15 minutes, depending on cpu/network)
...

vagrant up --no-parallel
It's running from directory - <WORKING DIR>/vagrant/multi-servers
nodesDir = <WORKING DIR>/vagrant/multi-servers/provisioning/nodes ------------------------------------------------
The following Ansible playbooks are found:
...
Running ansible playbooks? [y/n]: y

...
Wait patiently 
(it could be over 15 minutes, depending on cpu/network)
...

```

**NOTE that if there's no ansible playbooks found, VM ansible-controller1 will not be created**

**Tips**

By involving may Vagrantfile(s), things can get slight more complex, and finding an error after waiting for almost an hour could be quite frustrating.

To avoid this:

A. Always run 'vagrant validate' before 'vagrant up' in order to let vagrant spot any syntax errors and fix them before running 'vagrant up'

B. For some cases 'vagrant validate' might not be enough for preventing runtime errors.

In order to reduce number of rumtime errors, this vagrant multi-servers template is shipped with an environment for rehearsal.
With this environment, you can use ruby to run the main Vagrantfile and all the sub Vagrantfile so as to have preview of what they are going to do.
So that you are able analyze, if all activities are in place and order before actually running them using 'vagrant up'

To make use of the rehearsal environment, please follow these below steps:

1. After you places all of your Vagrantfiles and related files under folder "provisioning/nodes", then change to directory "vagrant/multi-servers/dev"
2. Running command ./commands/update.sh
3. Then answser 'Y', when you are asked "Are you sure? [Y/n]"

