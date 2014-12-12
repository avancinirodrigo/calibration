--@example Basic example for testing Calibration type, 
--using a simple equation and variating it's x and y parameters.
-- local c = Calibration{
--	model = MyModel,
--	finalTime = 1,
--	parameters = {x ={ min = -100, max = 100, step = 2}, y = { -1, 2 ,3}},
--	fit = function(model)
--		return model.value
--	end
--}
require("calibration")


MyModel = Model{
	x = 1,
	y = 0,
	setup = function(self)
		self.t = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
		}
	end
}


c = Calibration{
	model = MyModel,
	finalTime = 1,
	parameters = {x ={ min = -100, max = 100, step = 2}, y = { -1, 2 ,3}},
	fit = function(model)
		return model.value
	end
}

local c2 = Calibration{
	model = MyModel,
	finalTime = 1,
	parameters = {x ={ min = -100, max = 100}, y = { min = 1, max = 10, step = 2}},
	fit = function(model)
		return model.value
	end
}


result = c:execute()
result2 = c2:execute()

print("result1: "..result.." result2: "..result2)
