class Drone
	attr_reader :id,:location,:destination,:max_weight,:status,:remaining_turns
	def initialize(id,initial_location,max_weight)
		@id = id
		@location = initial_location
		@max_weight = max_weight
		@items = Hash.new(0)
		@status = "waiting"
		@destination = nil
		@remaining_turns = 0
	end
	def load(ptype,quantity)
		if remaining_weight < ptype.weight * quantity
			raise "doesnt fit"
		elsif @status != "waiting"
			raise "you cannot operate a busy drone"
		else
			@items[ptype] += quantity 
			@remaining_turns = 1
			@status = "busy"
		end
	end
	def remaining_weight
		@max_weight - @items.inject(0) {|sum,(ptype,quantity)| sum + ptype.weight*quantity}
	end
	def available_items(ptype="all")
		return @items[ptype] unless ptype == "all"
		return @items.values.inject(:+)
	end
	def available_ptypes()
		@items.select{|k,v| v > 0}.keys
	end
	def deliver(ptype, quantity)
		if available_items(ptype) < quantity
			raise "not enough items"
		elsif @status != "waiting"
			raise "you cannot operate a busy drone"
		else
			@items[ptype] -= quantity 
			@remaining_turns = 1
			@status = "busy"
		end
	end
	def move(destination,turns)
		@destination = destination
		@remaining_turns = turns
		@status = "busy"
	end
	def tic
		@remaining_turns -=1 unless @status == "waiting" 
		if @remaining_turns == 0 and status == "busy"
			@location = @destination unless @destination == nil
			@destination = nil
			@status = "waiting"
		end
	end
end
