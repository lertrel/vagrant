##############################################################################
# !!!The first 10 lines are managed by dev commands, do not make any changes to them
# Please start coding from line 11, otherwise some lines will be lost
##############################################################################
#!/usr/bin/ruby -w

$LOAD_PATH << Dir.pwd
$LOAD_PATH << '/vagrant'
require "mock-vagrant.rb"
CURRENT_DIR = '/vagrant'
# #############################################################################
# Constants
# #############################################################################
require 'json'
require 'fileutils'
require File.join(CURRENT_DIR, 'multi-server.rb')

BASE_BOX = "hashicorp/bionic64"
RUN_PLAYBOOK_BY_DEFAULT = false
RUN_PLAYBOOK_REMOTE = true
RUN_PLAYBOOK_AS_BATCH= false



# #############################################################################
# Main
# #############################################################################

# Some shared values can be setup here
context = MultiServer.get_context

context["CURRENT_DIR"] = CURRENT_DIR
context["BASE_IP"] = "172.17.10"
context["RUN_PLAYBOOK_AS_BATCH"] = RUN_PLAYBOOK_AS_BATCH

# Displaying the current working folder
puts "It's running from directory - #{CURRENT_DIR}"

# Extracting folder with Vagrantfile
# Check to see if there's a folder provisioning/nodes
# under the current working directory
#nodesDir = File.join(CURRENT_DIR, PROVISIONING_DIR, NODES_DIR)
nodesDir = MultiServer.fullpath_of("", MultiServer.get_nodes_dir)
vagrantDirs = MultiServer.extract_folders_with_vagrantfile_from(nodesDir)

puts("No folder found with #{MultiServer::VAGRANTFILE} under #{nodesDir}") if vagrantDirs.empty?

if !vagrantDirs.empty?

	vagrantDirs.each {|nodeDir| MultiServer.parse_node(nodeDir, MultiServer.get_nodes_dir)}


	# Report the list of found Ansible playbooks
	sortedPlaybooks = MultiServer.retrieve_playbook_list

	if sortedPlaybooks.empty?
		puts "There is no Ansible playbooks found ... "
	else
		# List all sorted playbooks
		puts "The following Ansible playbooks are found:"
		sortedPlaybooks.each {|playbook| puts "Play book --> #{MultiServer.get_provisioning_dir}/#{playbook}"}

		if !MultiServer.has_controller_been_created

			MultiServer.confirmAndProcess("Running ansible playbooks", RUN_PLAYBOOK_BY_DEFAULT) do |action|

				if RUN_PLAYBOOK_REMOTE
					MultiServer.parse_ansible_controller(sortedPlaybooks)
				end
			end
		end
	end

	Vagrant.configure("2") do |config|

		MultiServer::set_parent_vagrant_config config
		config.vm.box = BASE_BOX

		MultiServer.parse_ansible_controller(sortedPlaybooks) if MultiServer.has_controller_been_created && RUN_PLAYBOOK_REMOTE
		MultiServer.load_found_vagrantfiles

		if !RUN_PLAYBOOK_REMOTE

			MultiServer.confirmAndProcess("Running ansible playbooks", RUN_PLAYBOOK_BY_DEFAULT) do |action|
				MultiServer.run_playbook_local(sortedPlaybooks, config)
			end
		end
	end
end
