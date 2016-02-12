require 'map'

#
# May not be required in the end.. no logic there?
#

describe Map do
	before do
		@rows = 101
		@columns = 150
		@map = Map.new(@columns,@rows)
	end
	it "can be created and it has the right sizes" do
		expect(@map.ncolumns).to be == @columns
		expect(@map.nrows).to be == @rows
	end

end
