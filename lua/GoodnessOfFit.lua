
--@header Goodness-of-fit metrics.

--- Compare two continuous cellular spaces pixel by pixel
-- @param cs1 First Cellular Space.
-- @param cs2 Second Cellular Space.
-- @param attribute1 attribute from the first cellular space that should be compared
-- @param attribute2 attribute from the second cellular space that should be compared
-- @usage continuousPixelByPixel(cs1, cs2, "attribute1", "attribute2")
continuousPixelByPixel = function(cs1, cs2, attribute1, attribute2)
	-- cs1 tem attribute1 cs1.cells[1][attribute1] ~= nil
	-- attributes string
	-- cs2 tem attribute2

	-- TODO: este soh aceita valores numericos type(cs1.cells[attribute1]) e type(cs2.cells[attribute2])

	if cs1 == nil then
		 mandatoryArgumentError("#1")
	elseif type(cs1) ~= "CellularSpace" then
		incompatibleTypeError(1, "CellularSpace", cs1)
	end
	
	if cs2 == nil then
		 mandatoryArgumentError("#2")
	elseif type(cs2) ~= "CellularSpace" then
		incompatibleTypeError("#2", "CellularSpace", cs2)	
	end
	
	if attribute1 == nil then
		 mandatoryArgumentError("#3")
	elseif type(attribute1) ~= "string" then
		incompatibleTypeError("#3", "String", attribute1)
	end
	
	if attribute2 == nil then
		 mandatoryArgumentError("#4")
	elseif type(attribute2) ~= "string" then
		incompatibleTypeError("#4", "String", attribute2)
	end

	verify(cs1.cells[1][attribute1] ~= nil, "Attribute "..attribute1.." was not found in the CellularSpace.")

	if cs2.cells[1][attribute2] == nil then
		customError("Attribute "..attribute2.." was not found in the CellularSpace.")
	end
	
	local counter = 0
	local dif = 0
	forEachCellPair(cs1, cs2, function(cell1, cell2) 
    	dif = dif + (cell1[attribute1] - cell2[attribute2])
		counter = counter + 1
	end)
	
	return dif/counter
end

--- Compare two discrete cellular spaces pixel by pixel
-- @param cs1 First Cellular Space.
-- @param cs2 Second Cellular Space.
-- @param attribute1 attribute from the first cellular space that should be compared
-- @param attribute2 attribute from the second cellular space that should be compared
-- @usage discretePixelByPixelString(cs1, cs2, "attribute1", "attribute2")
discretePixelByPixelString = function(cs1, cs2, attribute1, attribute2)
	-- TODO: pode ser numerico ou string

	if cs1 == nil then
		 mandatoryArgumentError("#1")
	elseif type(cs1) ~= "CellularSpace" then
		incompatibleTypeError("#1", "CellularSpace", cs1)
	end
	
	if cs2 == nil then
		 mandatoryArgumentError("#2")
	elseif type(cs2) ~= "CellularSpace" then
		incompatibleTypeError("#2", "CellularSpace", cs2)	
	end
	
	if attribute1 == nil then
		 mandatoryArgumentError("#3")
	elseif type(attribute1) ~= "string" then
		incompatibleTypeError("#3", "string", attribute1)
	end
	
	if attribute2 == nil then
		 mandatoryArgumentError("#4")
	elseif type(attribute2) ~= "string" then
		incompatibleTypeError("#4", "string", attribute2)
	end

	if cs1.cells[1][attribute1] == nil then
		customError("Attribute "..attribute1.." was not found in the CellularSpace.")
	end

	if cs2.cells[1][attribute2] == nil then
		customError("Attribute "..attribute2.." was not found in the CellularSpace.")
	end

	-- TODO: #cs1 == #cs2
	
	local counter = 0
	local equal = 0
	forEachCellPair(cs1, cs2, function(cell1, cell2) 
    		if cell1[attribute1] == cell2[attribute2] then
				equal = equal + 1		
			end
		counter = counter + 1
	end)
	
	return equal/counter
end

local discreteSquareBySquare = function(dim, cs1, cs2, x, y, attribute) -- function that returns the fitness of a particular dimxdim Costanza square.
	local squareTotalFit = 0
	local squareDif = 0
	local squareFit = 0
	local squareTotalFit = 0
	local forCounter = 0
	-- TODO: i = cs1.xmin ate xmax
	-- TODO use minCol and minRow
	local t1, t2
	for i = 0, ((y - dim) + 1) do -- for each line
		for j = 0, ((x - dim) + 1) do -- for each column
			forCounter = forCounter + 1
			t1 = Trajectory{ -- select all elements belonging to the dim x dim  square  in cs1,  starting from the element in colum j and line x.
				target = cs1,
				select = function(cell) return (cell.x < dim + j) and (cell.y < dim + i) and (cell.x >= j) and (cell.y >=  i) end
			}
			t2 = Trajectory{ -- select all elements belonging to the dim x dim  square  in cs1,  starting from the element in colum j and line x.
				target = cs2,
				select = function(cell) return (cell.x < dim + j) and (cell.y < dim + i) and (cell.x >= j) and (cell.y >=  i ) end
			}
			local counter1 = {}
			local counter2 = {}
			forEachCell(t1, function(cell1) 
					local value1 = cell1[attribute]
					-- print(cell1.x..","..cell1.y)
		    		if counter1[value1] == nil then
						counter1[value1] = 1
					else
						counter1[value1] = counter1[value1] + 1
					end

					if counter2[value1] == nil then
						counter2[value1] = 0
					end
			end)

			forEachCell(t2, function(cell2) 
					local value2 = cell2[attribute]
	
		    		if counter2[value2] == nil then
							counter2[value2] = 1
					else
						counter2[value2] = counter2[value2] + 1
					end

					if counter1[value2] == nil then
						counter1[value2] = 0
					end
			end)
			-- print ("separator")
			local dif = 0
			forEachElement(counter1, function(idx, value)
				dif = math.abs(value - counter2[idx]) + dif
				-- print("dif: "..dif)
			end)
			-- print("Dif: "..dif)

			squareDif = dif/(dim*dim*2)
			--print("SquareDif: "..squareDif.."size: "..dim)

			-- print("SquareDif"..squareDif)
			squareFit = 1 - squareDif -- calculate a particular  dimxdim square fitness
			squareTotalFit = squareTotalFit + squareFit -- calculates the fitness of all dimxdim squares
		end
	end
	return squareTotalFit/forCounter -- returns the fitness of all the squares divided by the number of squares.
end

--- Compare two discrete cellular spaces according to the calibration method described in Costanza's paper
-- @param cs1 First Cellular Space.
-- @param cs2 Second Cellular Space.
-- @param attribute An attribute present in both cellular space, which values should be compared
-- @usage discreteCostanzaMultiLevel(cs1, cs2, "attribute")
discreteCostanzaMultiLevel = function(cs1, cs2, attribute)
	-- supposes numeric attributes (1 or different than 1)

	if cs1 == nil then
		 mandatoryArgumentError("#1")
	elseif type(cs1) ~= "CellularSpace" then
		incompatibleTypeError("#1", "CellularSpace", cs1)
	end

	if cs2 == nil then
		 mandatoryArgumentError("#2")
	elseif type(cs2) ~= "CellularSpace" then
		incompatibleTypeError("#2", "CellularSpace", cs2)	
	end
	
	if attribute == nil then
		 mandatoryArgumentError("#3")
	elseif type(attribute) ~= "string" then
		incompatibleTypeError("#3", "string", attribute1)
	end
	local k = 0.1 -- value that determinate weigth for each square calibration

	-- attribute value can be 0 or 1 and celluarSpaces xdDim = yDim;
	local exp = 1
	local fitnessSum = discretePixelByPixelString(cs1, cs2, attribute, attribute) -- fitnessSum is the Sum of all the fitness from each square ixi , it is being initialized as the fitnisess of the 1x1 square, 
	local x = cs1.xdim
	local y = x
	for i=2,(x+1) do -- increase the square size and calculate fitness for each square.
	fitnessSum = fitnessSum + discreteSquareBySquare(i, cs1, cs2, x, y, attribute) * math.exp(-k*(i - 1 ))
	exp = exp + math.exp(-k*(i - 1))
	end

	local fitness = fitnessSum/exp
	-- print("Squarebysquare value: "..discreteSquareBySquare(1, cs1, cs2, x, y, attribute).." should be equal to: "..discretePixelByPixelString(cs1, cs2, attribute, attribute))
	return fitness
end

local continuousSquareBySquare = function(dim, cs1, cs2, x, y, attribute) -- function that returns the fitness of a particular dimxdim Costanza square.
	local squareTotalFit = 0
	local squareDif = 0
	local squareFit = 0
	local squareTotalFit = 0
	-- TODO: i = cs1.xmin ate xmax

	for i=1, ((x-dim)+1) do -- for each line
		for j=1, ((y-dim)+1) do -- for each column
			local t1 = Trajectory{ -- select all elements belonging to the dim x dim  square  in cs1,  starting from the element in colum j and line x.
				target = cs1,
				select = function(cell) return (cell.x < ((dim * i)) and cell.y < ((dim * j)) and cell.x >= (i-1) and cell.y >= (j-1)) end
			}
			local t2 = Trajectory{ -- select all elements belonging to the dim x dim  square  in cs2,  starting from the element in colum j and line x.
				target = cs2,
				select = function(cell) return (cell.x < ((dim * i)) and cell.y < ((dim * j)) and cell.x >= (i-1) and cell.y >= (j-1)) end
			}
			local counter1 = 0
			local counter2 = 0

			forEachCell(t1, function(cell1) 
				counter1 = counter1 + cell1[attribute]
			end)

			forEachCell(t2, function(cell2) 
				counter2 = counter2 + cell2[attribute]
			end)
			
			local dif = 0
			dif = math.abs(counter1, counter2)

			squareDif = dif/(dim*dim)
			squareFit = 1 - squareDif -- calculate a particular  dimxdim square fitness
			squareTotalFit = squareTotalFit + squareFit -- calculates the fitness of all dimxdim squares
		end
	end
	return squareTotalFit/(((x-dim)+1)+((y-dim)+1)) -- returns the fitness of all the squares divided by the number of squares.
end

--- Compare two continuous cellular spaces according to the calibration method described in Costanza's paper.
-- @param cs1 First Cellular Space.
-- @param cs2 Second Cellular Space.
-- @param attribute An attribute present in both cellular space, which values should be compared.
-- @usage continuousCostanzaMultiLevel(cs1, cs2, "attribute")
continuousCostanzaMultiLevel = function(cs1, cs2, attribute)
	-- supposes numeric attributes (1 or different than 1)

	if cs1 == nil then
		 mandatoryArgumentError("#1")
	elseif type(cs1) ~= "CellularSpace" then
		incompatibleTypeError("#1", "CellularSpace", cs1)
	end

	if cs2 == nil then
		 mandatoryArgumentError("#2")
	elseif type(cs2) ~= "CellularSpace" then
		incompatibleTypeError("#2", "CellularSpace", cs2)	
	end
	
	if attribute == nil then
		 mandatoryArgumentError("#3")
	elseif type(attribute) ~= "string" then
		incompatibleTypeError("#3", "string", attribute1)
	end

	-- attribute value can be 0 or 1 and celluarSpaces xdDim = yDim;
	fitnessSum = continuousPixelByPixel(cs1, cs2, attribute, attribute) -- fitnessSum is the Sum of all the fitness from each square ixi , it is being initialized as the fitnisess of the 1x1 square
	local x= cs1.xdim
	local y = x
	
	for i=2,x do -- increase the square size and calculate fitness for each square.
		fitnessSum = fitnessSum + continuousSquareBySquare(i, cs1, cs2, x, y, attribute)
	end

	local fitness = fitnessSum/(x*y)
	return fitness
end

--- Function under development.
-- @param cs1 First Cellular Space.
-- @param cs2 Second Cellular Space.
-- @param attribute An attribute present in both cellular space, which values should be compared.
-- @param demand parameter under development.
-- @usage multiLevelDemand(cs1, cs2, "attribute", 5)
multiLevelDemand = function(cs1, cs2, attribute, demand)
	-- cs1 tem attribute1
	-- cs2 tem attribute2
	-- demand > 0

	if cs1 == nil then
		 mandatoryArgumentError("#1")
	elseif type(cs1) ~= "CellularSpace" then
		incompatibleTypeError("#1", "CellularSpace", cs1)
	end
	
	if cs2 == nil then
		 mandatoryArgumentError("#2")
	elseif type(cs2) ~= "CellularSpace" then
		incompatibleTypeError("#2", "CellularSpace", cs2)	
	end
	
	if attribute == nil then
		 mandatoryArgumentError("#3")
	elseif type(attribute) ~= "string" then
		incompatibleTypeError("#3", "string", attribute1)
	end
	
	if demand == nil then
		mandatoryArgumentError("#4")
	elseif type(demand) ~= "number" then
		incompatibleTypeError("#4", "number", demand)
		 
	elseif demand <= 0 then
		customError("Demand should be bigger than 0.")		
	end
end

