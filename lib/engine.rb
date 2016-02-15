class Engine
	def load(environment)
		@ptypes = environment[:ptypes]
		@warehouses = environment[:warehouses].clone
		@orders = environment[:orders].clone
		@drones = environment[:drones].clone
	end
end

class DummyEngine < Engine
	def run
	end
end

class OrderPerspectiveEngine < Engine
	def drones_here_for_delivery(order)
		@drones.select do |drone| 
			drone.location == order.delivery_address and drone.status == "waiting" and (drone.available_ptypes - order.pending_delivery_items).size > 0
		end
	end
	def waiting_drones_carrying_what_i_want(order)
		@drones.select do |drone| 
			drone.status == "waiting" and (drone.available_ptypes & order.pending_delivery_items).size > 0
		end
	end
	def closest_warehouse_with_my_item(item,location)
		candidates = @warehouses.select do |warehouse|
			warehouse.available_items(item) > 0 
		end
		candidates.min do |warehouse_a,warehouse_b|
			distance(warehouse_a.location,distance) <=> distance(warehouse_b.location,distance)
		end
	end
	def closest_idle_drone(location)
		candidates = @drones.select do |drone|
			drone.status == "waiting" #and drone.available_items == 0
		end
		puts "DEBUG: looks I have the following tentative candidates:  #{candidates.inspect}"
		puts "DEBUG: while the list of drones is:  #{@drones.inspect}"
		candidates.min do |warehouse_a,warehouse_b|
			warehouse_a.location.distance(location) <=> warehouse_b.location.distance(location)
		end
	end
	def run
		while $current_turn < $max_turns 
			# optimization: distribute drones
			# optimization: balancing drones selection
			@orders.select {|order| order.status="pending"}.each do |order|
				# optimization: order of orders
				# optimization: grouping orders (area, items...)
				
				# Deliver my item!
				drones_here_with_my_item = drones_here_for_delivery(order)
				puts "DEBUG: number of drones here and with my item: #{drones_here_with_my_item.size}"
				drones_here_with_my_item.each do |drone|
					item_i_want = (drone.available_ptypes & order.pending_delivery_items).sample
					quantity_to_request = [order.pending_delivery_qty(item_i_want),drone.available_items(item_i_want)].min 
					drone.deliver(item_i_want,quantity_to_request)
				end	
				# optimization: bring drones that may have the item i want in the inventory
				# find_closest_warehouse!
				order.pending_pick_items.each do |pending_to_pick|
					warehouse = closest_warehouse_with_my_item(pending_to_pick,order.delivery_address)
					puts "DEBUG: I found one warehouse with my item: #{warehouse.id}"
					# optimization: reserve the item
					# find_closest_empty_drone_from_warehouse
					drone = closest_idle_drone(warehouse.location) 
					puts drone != nil ? "DEBUG: I found one drone to bring my item: #{drone.id}" : "DEBUG: no drone available"
					# if its_there_pick and unloading_if_required
					# optimization: picking more may have sense
					# optimization: start checking if quantity is enough, or look for more warehouses and drones)
					# else send_to_warehouse
				end
			end
			$current_turn += 1
			@drones.each {|drone| drone.tic}
		end
	end
end
