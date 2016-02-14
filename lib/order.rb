LineStatus = Struct.new(:requested,:ongoing,:delivered)

class Order
	attr_accessor :id,:delivery_address,:status,:closed_turn
	def initialize(id, delivery_address)
		@id = id
		@delivery_address = delivery_address
		@items = Hash.new {|hash, key| hash[key] = LineStatus.new(0,0,0)}
		@status = "pending"
		@closed_turn = nil
	end
	def add_items(ptype,quantity)
		@items[ptype].requested += quantity 
	end
	def item_picked(ptype,quantity) 
		@items[ptype].ongoing += quantity
	end
	def item_delivered(ptype,quantity) 
		@items[ptype].ongoing -= quantity
		@items[ptype].delivered += quantity
		if pending_delivery_qty == 0
			@status = "closed"
			@closed_turn = $current_turn
		end
	end
	def requested_items()
		@items.keys
	end
	def requested_qty(ptype="all")
		return @items.values.inject(0) {|sum,line| sum = sum + line.requested} if ptype == "all"
		return @items[ptype].requested
	end
	def ongoing_items
		return @items.select {|item,line| line.ongoing > 0}.keys
	end
	def ongoing_qty(ptype="all")
		return @items.values.inject(0) {|sum,line| sum = sum + line.ongoing} if ptype == "all"
		return @items[ptype].ongoing
	end
	def delivered_items
		return @items.select {|item,line| line.delivered > 0}.keys
	end
	def delivered_qty(ptype="all")
		return @items.values.inject(0) {|sum,line| sum = sum + line.delivered} if ptype == "all"
		return @items[ptype].delivered
	end
	def pending_delivery_items
		return @items.select {|item,line| line.delivered != line.requested}.keys
	end
	def pending_delivery_qty(ptype="all")
		return @items.values.inject(0) {|sum,line| sum = sum + line.requested - line.delivered} if ptype == "all"
		return requested_qty(ptype) - delivered_qty(ptype)
	end
	def pending_pick_items
		return @items.select {|item,line| line.delivered + line.ongoing != line.requested}.keys
	end
	def pending_pick_qty(ptype="all")
		return @items.values.inject(0) {|sum,line| sum = sum + line.requested - line.delivered - line.ongoing} if ptype == "all"
		return requested_qty(ptype) - delivered_qty(ptype) - ongoing_qty(ptype)
	end
	def score
		if @status == "closed" and @closed_turn < $max_turn
			return (($max_turn-@closed_turn)*100/($max_turn + 0.00)).ceil
		else
			return 0
		end
	end

end

