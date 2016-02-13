require 'location'

describe Location do
	it "can be created and it has the expected properties" do
		x = rand(1..100)
		y = rand(1..100)
		location = Location.new(x,y)
		expect(location.x).to be == x
		expect(location.y).to be == y
	end
	it "calculates distance between locations" do
		location_a = Location.new(0,0)
		location_b = Location.new(1,1)
		expect(location_a.distance(location_b)).to be == 2
		location_c = Location.new(2,2)
		expect(location_a.distance(location_c)).to be == 3
		location_d = Location.new(0,9)
		expect(location_a.distance(location_d)).to be == 9
	end

end
