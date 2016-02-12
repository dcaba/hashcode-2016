require 'product_type'
require 'location'

describe Order do
	before do
		@olocation = Location.new(rand(1..100),rand(1..100))
		@ptype1 = ProductType.new(1,100)
		@ptype2 = ProductType.new(2,150)
		@order = Order.new(0,@olocation)
		@order.add_items(@ptype1,2)
		@order.add_items(@ptype2,1)
	end
	it "has the expected initial properties" do
		expect(@order.delivery_address).to be == @olocation
		expect(@order.required_items(@ptype1)).to be == 2
		expect(@order.required_items(@ptype2)).to be == 1
		expect(@order.status).to be == 'pending'
		expect(@order.id).to be == 0
		expect(@order.ongoing_items(@ptype1)).to be == 0
		expect(@order.ongoing_items(@ptype2)).to be == 0
		expect(@order.delivered_items(@ptype1)).to be == 0
		expect(@order.delivered_items(@ptype2)).to be == 0
		expect(@order.pending_delivery).to be == 3
		expect(@order.pending_delivery(@ptype1)).to be == 2
		expect(@order.pending_delivery(@ptype2)).to be == 1
		expect(@order.pending_pick).to be == 3
		expect(@order.pending_pick(@ptype1)).to be == 2
		expect(@order.pending_pick(@ptype2)).to be == 1
	end

	it "once some items are picked, properties are accordingly announced" do
		@order.item_picked(@ptype1,1)
		@order.item_picked(@ptype2,1)
		expect(@order.status).to be == 'pending'
		expect(@order.ongoing_items(@ptype1)).to be == 1
		expect(@order.ongoing_items(@ptype2)).to be == 1
		expect(@order.delivered_items(@ptype1)).to be == 0
		expect(@order.delivered_items(@ptype2)).to be == 0
		expect(@order.pending_delivery).to be == 3
		expect(@order.pending_delivery(@ptype1)).to be == 2
		expect(@order.pending_delivery(@ptype2)).to be == 1
		expect(@order.pending_pick).to be == 1
		expect(@order.pending_pick(@ptype1)).to be == 1
		expect(@order.pending_pick(@ptype2)).to be == 0
	end

	it "once some items are delivered, properties are accordingly announced" do
		@order.item_picked(@ptype1,1)
		@order.item_picked(@ptype2,1)
		@order.item_delivered(@ptype2,1)
		expect(@order.status).to be == 'pending'
		expect(@order.ongoing_items(@ptype1)).to be == 1
		expect(@order.ongoing_items(@ptype2)).to be == 0
		expect(@order.delivered_items(@ptype1)).to be == 0
		expect(@order.delivered_items(@ptype2)).to be == 1
		expect(@order.pending_delivery).to be == 2
		expect(@order.pending_delivery(@ptype1)).to be == 2
		expect(@order.pending_delivery(@ptype2)).to be == 0
		expect(@order.pending_pick).to be == 1
		expect(@order.pending_pick(@ptype1)).to be == 1
		expect(@order.pending_pick(@ptype2)).to be == 0
	end

	it "once all items are delivered, properties are accordingly announced" do
		@order.item_picked(@ptype1,2)
		@order.item_picked(@ptype2,1)
		@order.item_delivered(@ptype1,2)
		@order.item_delivered(@ptype2,1)
		expect(@order.status).to be == 'closed'
		expect(@order.ongoing_items(@ptype1)).to be == 0
		expect(@order.ongoing_items(@ptype2)).to be == 0
		expect(@order.delivered_items(@ptype1)).to be == 2
		expect(@order.delivered_items(@ptype2)).to be == 1
		expect(@order.pending_delivery).to be == 0
		expect(@order.pending_delivery(@ptype1)).to be == 0
		expect(@order.pending_delivery(@ptype2)).to be == 0
		expect(@order.pending_pick).to be == 0
		expect(@order.pending_pick(@ptype1)).to be == 0
		expect(@order.pending_pick(@ptype2)).to be == 0
	end
end
