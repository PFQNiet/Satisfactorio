local source = graphics.."placeholders/parts.png"
local parts = {
	fill = {44,4},
	circle = {4,4},
	half = {
		left = {4,44},
		right = {44,44},
		top = {84,44},
		bottom = {124,44}
	},
	quarter = {
		topleft = {4,84},
		topright = {44,84},
		bottomleft = {84,84},
		bottomright = {124,84}
	},
	edge = {
		top = {4,124},
		right = {44,124},
		bottom = {84,124},
		left = {124,124}
	},
	input = {
		top = {4,164},
		right = {44,164},
		bottom = {84,164},
		left = {124,164}
	},
	output = {
		top = {4,204},
		right = {44,204},
		bottom = {84,204},
		left = {124,204}
	},
	merger = {
		north = {4,244},
		east = {44,244},
		south = {84,244},
		west = {124,244}
	},
	splitter = {
		north = {4,284},
		east = {44,284},
		south = {84,284},
		west = {124,284}
	},
	arrow = {
		north = {4,324},
		east = {44,324},
		south = {84,324},
		west = {124,324}
	},
	fuel = {84,4}
}

local function getPiece(coords, target)
	return {
		filename = source,
		size = 32,
		position = coords,
		shift = target
	}
end

local function new()
	local graphic = {}
	local functions = {}
	functions.result = function() return {layers=graphic} end
	functions.addBox = function(x, y, w, h, inputs, outputs)
		if h == 1 then
			if w == 1 then
				table.insert(graphic, getPiece(parts.circle, {x,y}))
			else
				table.insert(graphic, getPiece(parts.half.left, {x,y}))
				table.insert(graphic, getPiece(parts.half.right, {x+w-1,y}))
			end
		else
			if w == 1 then
				table.insert(graphic, getPiece(parts.half.top, {x,y}))
				table.insert(graphic, getPiece(parts.half.bottom, {x,y+h-1}))
			else
				local inputmap = {}
				local outputmap = {}
				for _,i in pairs(inputs) do inputmap[i[1].."x"..i[2]] = true end
				for _,i in pairs(outputs) do outputmap[i[1].."x"..i[2]] = true end
				local function getEdgeType(pos)
					local key = pos[1].."x"..pos[2]
					if inputmap[key] then return 'input' end
					if outputmap[key] then return 'output' end
					return 'edge'
				end
				table.insert(graphic, getPiece(parts.quarter.topleft, {x,y}))
				for i = x+1, x+w-2 do
					table.insert(graphic, getPiece(parts[getEdgeType{i,y}].top, {i,y}))
				end
				table.insert(graphic, getPiece(parts.quarter.topright, {x+w-1,y}))
				for j = y+1, y+h-2 do
					table.insert(graphic, getPiece(parts[getEdgeType{x,j}].left, {x,j}))
					for i = x+1, x+w-2 do
						table.insert(graphic, getPiece(parts.fill, {i,j}))
					end
					table.insert(graphic, getPiece(parts[getEdgeType{x+w-1,j}].right, {x+w-1,j}))
				end
				table.insert(graphic, getPiece(parts.quarter.bottomleft, {x,y+h-1}))
				for i = x+1, x+w-2 do
					table.insert(graphic, getPiece(parts[getEdgeType{i,y+h-1}].bottom, {i,y+h-1}))
				end
				table.insert(graphic, getPiece(parts.quarter.bottomright, {x+w-1,y+h-1}))
			end
		end
		return functions
	end
	functions.addIcon = function(icon, size, shift)
		table.insert(graphic, {
			filename = icon,
			size = 64,
			scale = size/64,
			shift = shift or {0,0}
		})
		return functions
	end
	functions.addMark = function(mark, direction, shift)
		table.insert(graphic, {
			filename = source,
			position = parts[mark][direction],
			size = 32,
			scale = 0.5,
			shift = shift or {0,0}
		})
		return functions
	end
	functions.addFuelMark = function(shift)
		table.insert(graphic, {
			filename = source,
			position = parts.fuel,
			size = 32,
			shift = shift or {0,0}
		})
		return functions
	end
	local fourway = {}
	fourway.result = function() return {
		north = graphic.north.result(),
		east = graphic.east.result(),
		south = graphic.south.result(),
		west = graphic.west.result()
	} end
	fourway.rotate = function(x,y,w,h, inputs, outputs)
		return -y-h+1, x, h, w, fourway.rotateVectors(inputs), fourway.rotateVectors(outputs)
	end
	fourway.rotateVectors = function(list)
		for i,vec in pairs(list) do list[i] = {vec[2] == 0 and 0 or -vec[2],vec[1]} end
		return list
	end
	fourway.addBox = function(x, y, w, h, inputs, outputs)
		graphic.north.addBox(x,y,w,h,inputs,outputs)
		x, y, w, h, inputs, outputs = fourway.rotate(x,y,w,h,inputs,outputs)
		graphic.east.addBox(x,y,w,h,inputs,outputs)
		x, y, w, h, inputs, outputs = fourway.rotate(x,y,w,h,inputs,outputs)
		graphic.south.addBox(x,y,w,h,inputs,outputs)
		x, y, w, h, inputs, outputs = fourway.rotate(x,y,w,h,inputs,outputs)
		graphic.west.addBox(x,y,w,h,inputs,outputs)
		return fourway
	end
	fourway.addIcon = function(icon, size, shift)
		graphic.north.addIcon(icon, size, shift)
		graphic.east.addIcon(icon, size, shift and {-shift[2],shift[1]})
		graphic.south.addIcon(icon, size, shift and {-shift[1],-shift[2]})
		graphic.west.addIcon(icon, size, shift and {shift[2],-shift[1]})
		return fourway
	end
	fourway.addFuelMark = function(shift)
		graphic.north.addFuelMark(shift)
		graphic.east.addFuelMark(shift and {-shift[2],shift[1]})
		graphic.south.addFuelMark(shift and {-shift[1],-shift[2]})
		graphic.west.addFuelMark(shift and {shift[2],-shift[1]})
		return fourway
	end
	fourway.north = function() return graphic.north end
	fourway.east = function() return graphic.east end
	fourway.south = function() return graphic.south end
	fourway.west = function() return graphic.west end
	functions.fourway = function()
		graphic.north = new()
		graphic.east = new()
		graphic.south = new()
		graphic.west = new()
		return fourway
	end
	return functions
end

return new
