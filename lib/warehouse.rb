class Warehouse 
	attr_reader :id,:location
	def initialize(id,location)
		@id = id
		@location = location
		@inventory = Hash.new(0)
	end
	def add_items(ptype, quantity)
		@inventory[ptype] += quantity
	end
	def available_items(ptype)
		@inventory[ptype]
	end
	def pick(ptype,quantity)
		@inventory[ptype] -= quantity
	end
end
