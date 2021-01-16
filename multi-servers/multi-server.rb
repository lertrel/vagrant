module MultiServer


# #############################################################################
# Module Variables
# #############################################################################
VAGRANTFILE = "Vagrantfile"
PLAYBOOK_PATTERN = /\/([0-9]+).*\.yml/ 

@@parentVagrantConfig = nil
@@provisioningDir = "provisioning"
@@nodesDir = "nodes"
@@controllerDir = "controller"
@@controllerName = "ansible-controller1"
@@controllerKey = ".vagrant/machines/#{@@controllerName}/virtualbox/private_key"
@@vmRepo = ".vagrant/customs/vm-map.json";

@@context = Hash.new
@@vagrantFiles = Array.new
@@playbooks = Array.new


# #############################################################################
# Classes
# #############################################################################

class VMMapRepository

	def initialize(path)
		@path = path
		@json = Hash.new
	end

	def load
		@json = JSON.parse(File.read(@path)) if File.file? @path
	end

	def update(node)
		name = node["name"]
		@json["#{name}"] = node
	end

	def get(name)
		keyFile = ".vagrant/machines/#{name}/virtualbox/private_key"

		if File.file?(keyFile)
			return @json[name]
		else
			return nil
		end
	end

	def list

		result = Array.new

		@json.each do |key, node|
			node = get(key)
			result.push(node) if !node.nil?
		end

		return result
	end

	def save
		dirName = File.dirname(@path)
		FileUtils.mkdir_p(dirName) if !File.directory?(dirName)

		File.open(@path, "w") do |file|
			JSON.dump(@json, file)
		end
	end
end



# #############################################################################
# Functions
# #############################################################################

def self.get_context
	return @@context
end

def self.set_parent_vagrant_config(config)
	@@parentVagrantConfig = config
end

def self.get_parent_vagrant_config
	return @@parentVagrantConfig
end

def self.get_provisioning_dir
	return @@provisioningDir
end

def self.set_provisioning_dir(path)
	@@provisioningDir = path
end

def self.get_nodes_dir
	return @@nodesDir
end

def self.set_nodes_dir(path)
	@@nodesDir = path
end

def self.get_controller_dir
	return @@contronllerDir
end

def self.set_controller_dir(path)
	@@controllerDir = path
end

def self.get_controller_name
	return @@controllerName
end

def self.set_controller_name(name)
	@@controllerName = name
	@@controllerKey = ".vagrant/machines/#{@@controllerName}/virtualbox/private_key"
end

def self.get_vm_repository_filename
	return @@vmRepo
end

def self.set_vm_repository_filename(file)
	@@vmRepo = file
end



# Function for sub Vagrantfile to register created VMs and IPs for the sake of 
# generating ansible inventor
def self.register_vm_ip(vm, ip)

	repo = VMMapRepository.new(@@vmRepo)
	repo.load

	node = Hash.new

	node["name"] = vm
	node["ip"] = ip

	repo.update(node)
	repo.save

end

def self.fullpath_of(path, type)

	if path.empty?
		return File.join(CURRENT_DIR, @@provisioningDir, type)
	else
		return File.join(CURRENT_DIR, @@provisioningDir, type, path)
	end
end

def self.parse_node(nodeDir, type)

	nodeDirFull = fullpath_of(nodeDir, type)
	puts("#{nodeDirFull} is not a directory so it's will be skipped") if !File.directory?(nodeDirFull)

	if File.directory?(nodeDirFull) && has_vagrantfile(nodeDirFull)
		@@vagrantFiles.push(nodeDirFull)
		register_playbooks(nodeDir, type)
	else
		puts "A #{VAGRANTFILE} could not be found in #{nodeDirFull}"
	end
end

# Check if there's a vagrant file in a node folder
def self.has_vagrantfile(nodeDir)
	return File.file?(File.join(nodeDir, VAGRANTFILE))
end

def self.load_vagrantfile(nodeDir)
	# Getting full path of the Vagrantfile under the current node folder
	vagrantfile = File.join(nodeDir, VAGRANTFILE)
	# The load the vagrant file, if it's exist
	puts "Load Vagrantfile = #{vagrantfile}"
	load vagrantfile if File.file?(vagrantfile)
end

def self.load_found_vagrantfiles
	@@vagrantFiles.each{|v| load_vagrantfile(v)}
end

# Collecting list of ansible playbook files under the current node folder
def self.register_playbooks(nodeDir, type)

	playbookDir = File.join(fullpath_of(nodeDir, type), "playbooks")

	if File.directory?(playbookDir)

		Dir.foreach(playbookDir) do |entry|
			case entry
			# Skip ., .., and hidden entries
			when ".", "..", /^\..+/
			else
				# Convert the entry back it's full path
				playbook = File.join(nodeDir, "playbooks", entry)
				# Skip all files, only proceed on a folder
				@@playbooks.push(playbook) if File.file?(fullpath_of(playbook, type)) && File.extname(playbook) == ".yml"
			end
		end
	end
end

def self.compare_playbook_order(a, b)

	aStartWithNumber = false
	bStartWithNumber = false
	aPrefix = 0;
	bPrefix = 0;

	#If a start with number e.g. 123playbook.yml
	if (a =~ PLAYBOOK_PATTERN)
		aStartWithNumber = true
		aPrefix = a.scan(PLAYBOOK_PATTERN).first.first.to_i
	end

	#If b start with number e.g. 456playbook.yml
	if (b =~ PLAYBOOK_PATTERN)
		bStartWithNumber = true
		bPrefix = b.scan(PLAYBOOK_PATTERN).first.first.to_i
	end

	#If only a starts with number, a should get higher priority
	if aStartWithNumber && !bStartWithNumber
		return -1
	#If only b starts with number, b should get higher priority
	elsif !aStartWithNumber && bStartWithNumber
		return 1
	#If both a & b don't start with number, having equal priority
	elsif !aStartWithNumber && !bStartWithNumber
		return 0
	#If both a & b start with number, lower number gets higher priority 
	else
		return aPrefix - bPrefix
	end
end

def self.extract_folders_with_vagrantfile_from(nodesDir)

	# List of directory with Vagrantfile
	vagrantDirs = Array.new

	puts("Nodes repository could not be found") if !File.directory?(nodesDir)
	puts "nodesDir = #{nodesDir} ------------------------------------------------"

	# If the nodes folder exists, iterating through it and processing each node
	if File.directory?(nodesDir)

		# Interate over each node folder to look up and execute Vagrantfile
		Dir.foreach(nodesDir) do |entry|

			case entry
			# Skip ., .., and hidden entries
			when ".", "..", /^\..+/
			else
				# Convert the entry back it's full path
				nodeDir = File.join(nodesDir, entry)
				# Skip all files, only register on a folder that has Vagrantfile
				if File.directory?(nodeDir)

					aVagrantfile = File.join(nodeDir, VAGRANTFILE)

					if File.file?(aVagrantfile)
						vagrantDirs.push(entry) if File.directory?(nodeDir)
					else
						puts "A #{VAGRANTFILE} could not be found in #{nodeDir}"
					end
				end
			end
		end
	end

	return vagrantDirs

end

def self.retrieve_playbook_list

	return @@playbooks.sort {|a, b| compare_playbook_order(a, b) }
end

def self.user_wants_to(action)

	print "#{action} [y/n]: "
	userInput = STDIN.gets.chomp
	puts ""

	return "Y" == userInput.strip.upcase
end

def self.confirmAndProcess(action, skip, &block)

	if skip || user_wants_to("#{action}?")

		puts "#{action} ..."
		block.call(action)
	end
end

def self.parse_ansible_controller(playbooks)
	
	puts "Parse ansible controller node ..."

	controllerDir = fullpath_of("", @@controllerDir)

	if File.directory?(controllerDir)
		parse_node("", @@controllerDir)
		prepare_playbook_list_for_controller(playbooks)
	else
		puts "Controller folder not found - #{controllerDir}"
	end
end

def self.prepare_playbook_list_for_controller(playbooks)

	playbooksFullpath = Array.new

	playbooks.each{|playbook| playbooksFullpath.push(File.join("/vagrant", @@provisioningDir, @@nodesDir, playbook)) }

	@@context["PLAYBOOKS"] = playbooksFullpath
end

def self.run_playbook_local(playbooks, config)
	
	puts "run_playbook_local is NOT yet supported ..."

end

def self.has_controller_been_created
	return File.file?(@@controllerKey)
end



end
