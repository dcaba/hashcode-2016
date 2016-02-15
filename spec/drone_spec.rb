require 'drone'
require 'product_type'
require 'location'

describe Drone do
	before do
		@ilocation = Location.new(0,0)
		@ptype = ProductType.new(1,100)
		@max_weight = 2000
		@drone = Drone.new(25,@ilocation,@max_weight)
		@drone.load(@ptype,10)
		@drone.tic # we realized loading a drone requires one cycle!
	end
	it "has the expected initial properties" do
		expect(@drone.location).to be == @ilocation
		expect(@drone.max_weight).to be == @max_weight
		expect(@drone.remaining_weight).to be == @max_weight-1000
		expect(@drone.available_items(@ptype)).to be == 10
		expect(@drone.status).to be == "waiting"
		expect(@drone.available_ptypes).to include @ptype
		expect(@drone.available_ptypes.size).to be == 1
	end
	it "items can be delivered" do
		@drone.deliver(@ptype,10)
		expect(@drone.available_items(@ptype)).to be == 0
		expect(@drone.remaining_weight).to be == @max_weight
	end
	it "additional items can be loaded" do
		@drone.load(@ptype,10)
		expect(@drone.available_items(@ptype)).to be == 20
		expect(@drone.remaining_weight).to be == 0
	end
	it "no more items that the ones that fit can be loaded" do
		expect do
			@drone.load(@ptype,11)
		end.to raise_exception(RuntimeError)
	end
	context "that is moving" do
		before do
			@new_location = Location.new(10,0)
			@drone.move(@new_location,@new_location.distance(@drone.location))
		end
		it "captures the new status properly" do
			expect(@drone.location).to be == @ilocation
			expect(@drone.destination).to be == @new_location
			expect(@drone.remaining_turns).to be == 10
			expect(@drone.status).to be == "busy"
		end

		it "cannot load or deliver" do
			expect do
				@drone.load(@ptype,1)
			end.to raise_exception(RuntimeError)
			expect do
				@drone.deliver(@ptype,1)
			end.to raise_exception(RuntimeError)
		end

		it "can load or deliver when arrives" do
			10.times do
				@drone.tic
			end
			expect(@drone.location).to be == @new_location
			expect(@drone.remaining_turns).to be == 0
			expect(@drone.status).to be == "waiting"
			@drone.load(@ptype,10)
			@drone.tic
			expect(@drone.available_items(@ptype)).to be == 20
			@drone.deliver(@ptype,20)
			@drone.tic
			expect(@drone.available_items(@ptype)).to be == 0
		end
	end
	context "with multiple object types" do
		before do
			@ptype2 = ProductType.new(2,100)
			@drone.load(@ptype2,5)
		end
		it "has the expected properties" do
			expect(@drone.remaining_weight).to be == 500
			expect(@drone.available_items).to be == 15
			expect(@drone.available_items(@ptype)).to be == 10
			expect(@drone.available_items(@ptype2)).to be == 5
			expect(@drone.available_ptypes).to include @ptype
			expect(@drone.available_ptypes).to include @ptype2
			expect(@drone.available_ptypes.size).to be == 2
		end


	end

end
