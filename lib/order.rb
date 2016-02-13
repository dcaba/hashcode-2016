LineStatus = Struct.new(:requested,:ongoing,:delivered)

class Order
	attr_accessor :id,:delivery_address,:status
	def initialize(id, delivery_address)
		@id = id
		@delivery_address = delivery_address
		@items = Hash.new {|hash, key| hash[key] = LineStatus.new(0,0,0)}
		@status = "pending"
	end
	def add_items(ptype,quantity)
		@items[ptype].requested += quantity 
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

end

