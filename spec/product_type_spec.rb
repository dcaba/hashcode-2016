require 'product_type'

describe ProductType do
	it "can be created and it has the expected properties" do
		type_id = rand(1..100)
		weight = 150
		ptype = ProductType.new(type_id,weight)
		expect(ptype.id).to be == type_id
		expect(ptype.weight).to be == weight
	end

end
