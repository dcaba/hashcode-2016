class Engine
	def load(environment)
		@ptypes = environment[:ptypes]
		@warehouses = environment[:warehouses].clone
		@orders = environment[:orders].clone
		@drones = environment[:drones].clone
	end
end

class DummyEngine < Engine
	@VERSION = 0.0
	class << self; attr_reader :VERSION; end;
	def run()
	end
end

class OrderPerspectiveEngine < Engine
	@VERSION = 0.1;
	class << self; attr_reader :VERSION; end;
	def drones_here_for_delivery(order)
		@drones.select do |drone| 
			drone.location == order.delivery_address and drone.status == "waiting" and (drone.available_ptypes & order.pending_delivery_items).size > 0
		end
	end
	def waiting_drones_carrying_what_i_want(ptype)
		@drones.select do |drone| 
			drone.status == "waiting" and drone.available_ptypes.include?(ptype)
		end
	end
	def closest_warehouse_with_my_item(item,location)
		candidates = @warehouses.select do |warehouse|
			warehouse.available_items(item) > 0 
		end
		candidates.min do |warehouse_a,warehouse_b|
			location.distance(warehouse_a.location) <=> location.distance(warehouse_b.location)
		end
	end
	def closest_idle_drone(location)
		candidates = @drones.select do |drone|
			drone.status == "waiting" #and drone.available_items == 0
		end
		puts "DEBUG: looks I have the following nmbr of tentative candidates:  #{candidates.size}"
		candidates.min do |warehouse_a,warehouse_b|
			warehouse_a.location.distance(location) <=> warehouse_b.location.distance(location)
		end
	end
	def run(params)
		puts "DEBUG: Param presorting is #{params[:pre_sorting]}"
		@orders.sort! {|a,b| a.pending_delivery_qty <=> b.pending_delivery_qty} if params[:pre_sorting] == 1
		while $current_turn < $max_turn 
			# optimization: distribute drones
			# optimization: balancing drones selection
			@orders.select {|order| order.status=="pending"}.each do |order|
				# optimization: order of orders
				# SMALLER FIRST?? closer??
				# optimization: grouping orders (area, items...)
				# actual action: Deliver my item!
				puts "DEBUG: Processing order #{order.id}"
				puts "DEBUG: Status of order 0 before processing: #{order.pending_delivery_qty},#{order.inspect}" if order.id == 0
				drones_here_with_my_item = drones_here_for_delivery(order)
				puts "DEBUG: number of drones here and with my item: #{drones_here_with_my_item.size}"
				drones_here_with_my_item.each do |drone|
					item_i_want = (drone.available_ptypes & order.pending_delivery_items).first
					quantity_to_request = [order.pending_delivery_qty(item_i_want),drone.available_items(item_i_want)].min 
					puts "DEBUG: deliverying #{quantity_to_request} items of #{item_i_want} "
					drone.deliver(item_i_want,quantity_to_request)
					order.item_delivered(item_i_want,quantity_to_request)
				end	
				# optimization: bring drones that may have the item i want in the inventory
				# actual_action: find_closest_warehouse!
				order.pending_pick_items.each do |pending_to_pick|
					puts "DEBUG: Tring to pick prod type #{pending_to_pick.id} of order #{order.id}"
					warehouse = closest_warehouse_with_my_item(pending_to_pick,order.delivery_address)
					puts "DEBUG: I found one warehouse with my item: #{warehouse.id}"
					# optimization: reserve the item
					# actual action: find_closest_empty_drone_from_warehouse
					drone = closest_idle_drone(warehouse.location) 
					puts drone != nil ? "DEBUG: I found one drone to bring my item: #{drone.id}" : "DEBUG: no drone available"
					next if drone == nil
					# actual action: if its_there_pick and unloading_if_required
					if drone.location == warehouse.location
						if drone.remaining_weight >= pending_to_pick.weight
							items_i_can_load = [drone.remaining_weight/pending_to_pick.weight,order.pending_pick_qty(pending_to_pick)].min
							puts "DEBUG: Loading drone #{drone.id} with #{items_i_can_load} items of #{pending_to_pick.id}"
							drone.load(pending_to_pick,items_i_can_load)
							order.item_picked(pending_to_pick,items_i_can_load)
							warehouse.pick(pending_to_pick,items_i_can_load)
						else 
							puts "DEBUG: Drone #{drone.id} in warehouse location is full"
						end

					else
						# optimization: should i move a drone with items? maybe we should let it deliver
						puts "DEBUG: Sending drone #{drone.id} to warehouse #{warehouse.id}"
						drone.move(warehouse.location,warehouse.location.distance(drone.location))
						# optimization: picking more, or the rest in my order if any, may have sense
						# optimization: start checking if quantity is enough, or look for more warehouses and drones)
					end
				end
				order.pending_delivery_items.each do |pending_to_deliver|
					# actual action: bring drones with my item and idle!!
					waiting_drones_carrying_what_i_want(pending_to_deliver).each do |drone|
						puts "DEBUG: Sending drone #{drone.id} to order address of #{order.id}"
						drone.move(order.delivery_address,drone.location.distance(order.delivery_address))
					end
				end
				puts "DEBUG: Status of order 0 before processing: #{order.pending_delivery_qty},#{order.inspect}" if order.id == 0
			end
			pending_orders = @orders.select {|order| order.status=="pending"}.size 
			puts "INFO: Orders pending to complete when closing #{$current_turn}: #{pending_orders} of #{@orders.size}"
			break if pending_orders == 0
			$current_turn += 1
			puts "DEBUG: Time passes away. Now we are in #{$current_turn}"
			@drones.each {|drone| drone.tic}

		end
		puts "INFO: Engine finished. Turns required = #{$current_turn} "
	end
end
