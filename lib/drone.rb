class Drone
	attr_accessor :location,:destination,:max_weight,:status,:remaining_turns
	def initialize(initial_location,max_weight)
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
			raise "you cannot operate a moving drone"
		else
			@items[ptype] += quantity 
		end
	end
	def remaining_weight
		@max_weight - @items.inject(0) {|sum,(ptype,quantity)| sum + ptype.weight*quantity}
	end
	def available_items(ptype)
		@items[ptype]
	end
	def deliver(ptype, quantity)
		if available_items(ptype) < quantity
			raise "not enough items"
		elsif @status != "waiting"
			raise "you cannot operate a moving drone"
		else
			@items[ptype] -= quantity 
		end
	end
	def move(destination,turns)
		@destination = destination
		@remaining_turns = turns
		@status = "moving"
	end
	def tic
		@remaining_turns -=1 unless @status == "waiting" 
		if @remaining_turns == 0 and status == "moving"
			@location = @destination
			@destination = nil
			@status = "waiting"
		end
	end
end
