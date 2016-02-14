require 'order'
require 'product_type'
require 'location'

describe Order do
	before do
		@olocation = Location.new(rand(1..100),rand(1..100))
		@ptype1 = ProductType.new(1,100)
		@ptype2 = ProductType.new(2,150)
		@order = Order.new(0,@olocation)
		@order.add_items(@ptype1,3)
		@order.add_items(@ptype2,1)
	end
	it "has the expected initial properties" do
		expect(@order.delivery_address).to be == @olocation
		expect(@order.id).to be == 0
		expect(@order.status).to be == 'pending'
		expect(@order.requested_items).to include @ptype1 
		expect(@order.requested_items).to include @ptype2 
		expect(@order.requested_qty).to be == 4 
		expect(@order.requested_qty(@ptype1)).to be == 3
		expect(@order.requested_qty(@ptype2)).to be == 1
		expect(@order.ongoing_items).to be_empty
		expect(@order.ongoing_qty).to be == 0
		expect(@order.ongoing_qty(@ptype1)).to be == 0
		expect(@order.ongoing_qty(@ptype2)).to be == 0
		expect(@order.delivered_items).to be_empty
		expect(@order.delivered_qty).to be == 0
		expect(@order.delivered_qty(@ptype1)).to be == 0
		expect(@order.delivered_qty(@ptype2)).to be == 0
		expect(@order.pending_delivery_items).to include @ptype1 
		expect(@order.pending_delivery_items).to include @ptype2 
		expect(@order.pending_delivery_qty).to be == 4
		expect(@order.pending_delivery_qty(@ptype1)).to be == 3
		expect(@order.pending_delivery_qty(@ptype2)).to be == 1
		expect(@order.pending_pick_items).to include @ptype1 
		expect(@order.pending_pick_items).to include @ptype2 
		expect(@order.pending_pick_qty).to be == 4
		expect(@order.pending_pick_qty(@ptype1)).to be == 3
		expect(@order.pending_pick_qty(@ptype2)).to be == 1
	end

	it "once some items are picked, properties are accordingly announced" do
		@order.item_picked(@ptype1,2)
		expect(@order.status).to be == 'pending'
		expect(@order.requested_items).to include @ptype1 
		expect(@order.requested_items).to include @ptype2 
		expect(@order.requested_qty).to be == 4 
		expect(@order.requested_qty(@ptype1)).to be == 3
		expect(@order.requested_qty(@ptype2)).to be == 1
		expect(@order.ongoing_items).to include @ptype1 
		expect(@order.ongoing_items).not_to include @ptype2 
		expect(@order.ongoing_qty).to be == 2
		expect(@order.ongoing_qty(@ptype1)).to be == 2
		expect(@order.ongoing_qty(@ptype2)).to be == 0
		expect(@order.delivered_items).to be_empty
		expect(@order.delivered_qty).to be == 0
		expect(@order.delivered_qty(@ptype1)).to be == 0
		expect(@order.delivered_qty(@ptype2)).to be == 0
		expect(@order.pending_delivery_items).to include @ptype1 
		expect(@order.pending_delivery_items).to include @ptype2 
		expect(@order.pending_delivery_qty).to be == 4
		expect(@order.pending_delivery_qty(@ptype1)).to be == 3
		expect(@order.pending_delivery_qty(@ptype2)).to be == 1
		expect(@order.pending_pick_items).to include @ptype1 
		expect(@order.pending_pick_items).to include @ptype2 
		expect(@order.pending_pick_qty).to be == 2
		expect(@order.pending_pick_qty(@ptype1)).to be == 1
		expect(@order.pending_pick_qty(@ptype2)).to be == 1
	end

	it "once some items are delivered, properties are accordingly updated" do
		$max_turn = 160
		$current_turn = 159
		@order.item_picked(@ptype1,1)
		@order.item_picked(@ptype2,1)
		@order.item_delivered(@ptype2,1)
		expect(@order.status).to be == 'pending'
		expect(@order.requested_items).to include @ptype1 
		expect(@order.requested_items).to include @ptype2 
		expect(@order.requested_qty).to be == 4 
		expect(@order.requested_qty(@ptype1)).to be == 3
		expect(@order.requested_qty(@ptype2)).to be == 1
		expect(@order.ongoing_items).to include @ptype1 
		expect(@order.ongoing_items).not_to include @ptype2 
		expect(@order.ongoing_qty).to be == 1
		expect(@order.ongoing_qty(@ptype1)).to be == 1
		expect(@order.ongoing_qty(@ptype2)).to be == 0
		expect(@order.delivered_items).not_to include @ptype1 
		expect(@order.delivered_items).to include @ptype2 
		expect(@order.delivered_qty).to be == 1
		expect(@order.delivered_qty(@ptype1)).to be == 0
		expect(@order.delivered_qty(@ptype2)).to be == 1
		expect(@order.pending_delivery_items).to include @ptype1 
		expect(@order.pending_delivery_items).not_to include @ptype2 
		expect(@order.pending_delivery_qty).to be == 3
		expect(@order.pending_delivery_qty(@ptype1)).to be == 3
		expect(@order.pending_delivery_qty(@ptype2)).to be == 0
		expect(@order.pending_pick_items).to include @ptype1 
		expect(@order.pending_pick_items).not_to include @ptype2 
		expect(@order.pending_pick_qty).to be == 2
		expect(@order.pending_pick_qty(@ptype1)).to be == 2
		expect(@order.pending_pick_qty(@ptype2)).to be == 0
		expect(@order.score).to be == 0
	end

	it "once all items are delivered, properties are accordingly announced" do
		$max_turn = 160
		$current_turn = 15
		@order.item_picked(@ptype1,2)
		@order.item_picked(@ptype2,1)
		@order.item_delivered(@ptype1,2)
		@order.item_delivered(@ptype2,1)
		@order.item_picked(@ptype1,1)
		@order.item_delivered(@ptype1,1)
		expect(@order.status).to be == 'closed'
		expect(@order.requested_items).to include @ptype1 
		expect(@order.requested_items).to include @ptype2 
		expect(@order.requested_qty).to be == 4 
		expect(@order.requested_qty(@ptype1)).to be == 3
		expect(@order.requested_qty(@ptype2)).to be == 1
		expect(@order.ongoing_items).to be_empty
		expect(@order.ongoing_qty).to be == 0
		expect(@order.ongoing_qty(@ptype1)).to be == 0
		expect(@order.ongoing_qty(@ptype2)).to be == 0
		expect(@order.delivered_items).not_to be_empty
		expect(@order.delivered_items).to include @ptype1 
		expect(@order.delivered_items).to include @ptype2 
		expect(@order.delivered_qty).to be == 4
		expect(@order.delivered_qty(@ptype1)).to be == 3
		expect(@order.delivered_qty(@ptype2)).to be == 1
		expect(@order.pending_delivery_items).not_to include @ptype1 
		expect(@order.pending_delivery_items).not_to include @ptype2 
		expect(@order.pending_delivery_qty).to be == 0
		expect(@order.pending_delivery_qty(@ptype1)).to be == 0
		expect(@order.pending_delivery_qty(@ptype2)).to be == 0
		expect(@order.pending_pick_items).not_to include @ptype1 
		expect(@order.pending_pick_items).not_to include @ptype2 
		expect(@order.pending_pick_qty).to be == 0
		expect(@order.pending_pick_qty(@ptype1)).to be == 0
		expect(@order.pending_pick_qty(@ptype2)).to be == 0
		expect(@order.score).to be == 91
	end
end
