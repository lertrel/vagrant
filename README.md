# vagrant
## Some useful Vagrantfile(s)

### 1. AWS-CLI Box

For setting a new box with AWS CLI

Please follow these steps
1. Make sure of having Virtualbox installed
2. Make sure of having Vagrant installed
3. Clone the current git repository
4. cd vagrant/aws
5. Copy an AWS credentials file (.csv) in vagrant/aws, and rename the file to 'credentials.csv'
6. Still inside vagrant/aws, running command 'vagrant up'
7. After the execution is complete, you can login to the created VM with command 'vagrant ssh'
8. Testing if aws-cli is working by running command 'aws --version'
9. If aws-cli command auto-completion is not working then running command 'complete -C /usr/local/bin/aws_completer aws'
10. Test it by running command 'aws iam list-users --profile <YOUR IAM USER>'
  
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
