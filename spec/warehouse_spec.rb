require 'warehouse'
require 'product_type'
require 'location'

describe Warehouse do
	before do
		@wlocation = Location.new(rand(1..100),rand(1..100))
		@ptype = ProductType.new(1,100)
		@warehouse = Warehouse.new(0,@wlocation)
		@warehouse.add_items(@ptype,50)
	end
	it "has the expected initial properties" do
		expect(@warehouse.location).to be == @wlocation
		expect(@warehouse.id).to be == 0
		expect(@warehouse.available_items(@ptype)).to be == 50
	end
	it "items can be picked" do
		@warehouse.pick(@ptype,10)
		expect(@warehouse.available_items(@ptype)).to be == 40
	end
	it "additional items can be stored" do
		@warehouse.add_items(@ptype,10)
		expect(@warehouse.available_items(@ptype)).to be == 60
	end

end
