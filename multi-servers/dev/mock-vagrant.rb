# #############################################################################
# Mock Components
# #############################################################################

class MockProvider

	attr_accessor :name, :memory, :cpus

	def initialize
		@name = "default"
		@memory = 256
		@cpus = 1
	end

end

class MockVM

	attr_accessor :box, :hostname

	def initialize
		@box = ""
		@hostname = ""
		@subConfig = nil
	end

	def getSubConfig()

		@subConfig = MockVagrantConfig.new if @subConfig.nil? 

		return @subConfig
	end

	def define(name, &block)

		c = getSubConfig

		block.call(c)
	end

	def provider(name, &block)

		p = MockProvider.new
		c = getSubConfig

		block.call(p, c)
		
	end

	def provision(name = "default", type, &inline)
		puts "MockVM.provision - #{name}"
		puts type[:type]
		puts type[:path]
		puts type[:inline]
		puts ""
	end

	def network(type, ip)
		puts "MockVM.network(#{type}, #{ip})"
	end
end

class MockVagrantConfig

	attr_reader :vm

	def initialize
		@vm = MockVM.new
	end

end

module Vagrant

	def self.configure(v, &block)

		puts "Vagrant.configure is called"

		config = MockVagrantConfig.new

		block.call(config)
	end
end



