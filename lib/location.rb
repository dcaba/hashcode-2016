Location = Struct.new(:x,:y)
class Location
	def distance(target)
		Math.sqrt(((target.x-x)**2)+((target.y-y)**2)).ceil
	end
end
