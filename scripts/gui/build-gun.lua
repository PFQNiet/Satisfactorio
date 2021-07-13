---@class BuildGunGui
---@field player LuaPlayer
---@field recipe LuaRecipePrototype
---@field components BuildGunGuiComponents

---@class BuildGunGuiComponents
---@field frame LuaGuiElement
---@field material_list LuaGuiElement
---@field materials table<string,BuildGunGuiMaterialComponent>

---@class BuildGunGuiMaterialComponent
---@field flow LuaGuiElement
---@field sprite LuaGuiElement
---@field bar LuaGuiElement

---@alias global.gui.build_gun table<uint, BuildGunGui>
---@type global.gui.build_gun
local script_data = {}

---@param player LuaPlayer
---@return BuildGunGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return BuildGunGui
local function createGui(player)
	local gui = player.gui.screen
	local frame = gui.add{
		type = "frame",
		direction = "vertical",
		ignored_by_interaction = true,
		style = "build_gun_frame"
	}
	local materials = frame.add{
		type = "flow",
		direction = "horizontal",
		style = "horizontal_flow_with_extra_spacing"
	}

	script_data[player.index] = {
		player = player,
		recipe = nil,
		components = {
			frame = frame,
			material_list = materials,
			materials = {}
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@param recipe LuaRecipePrototype|nil
---@param buffer LuaInventory|nil An additional buffer, such as from a mining event, whose items should also be counted
local function updateGUI(player, recipe, buffer)
	local data = getGui(player)
	if not data then data = createGui(player) end

	local frame = data.components.frame
	if not recipe then
		data.recipe = nil
		frame.visible = false
		return
	end

	local inventory = player.get_main_inventory().get_contents()
	if buffer then
		for k,v in pairs(buffer.get_contents()) do
			inventory[k] = (inventory[k] or 0) + v
		end
	end

	local list = data.components.material_list
	local mats = data.components.materials
	if recipe ~= data.recipe then
		data.recipe = recipe
		local product = game.item_prototypes[recipe.main_product.name]
		frame.caption = {"gui.build-gun-caption", product.name, product.localised_name}

		list.clear()
		for _,ingredient in pairs(recipe.ingredients) do
			local col = list.add{
				type = "flow",
				direction = "vertical"
			}
			local number = ingredient.amount
			local sprite = col.add{
				type = "sprite-button",
				style = "build_gun_slot",
				sprite = "item/"..ingredient.name,
				number = number
			}
			local bar = col.add{
				type = "progressbar",
				style = "build_gun_progressbar"
			}
			mats[ingredient.name] = {
				flow = col,
				sprite = sprite,
				bar = bar
			}
		end

		frame.visible = true
		frame.location = {(player.display_resolution.width-540*player.display_scale)/2, player.display_resolution.height-320*player.display_scale}
	end

	for _,ingredient in pairs(recipe.ingredients) do
		local parts = mats[ingredient.name]
		local satisfaction = player.cheat_mode and ingredient.amount or inventory[ingredient.name] or 0
		parts.bar.value = satisfaction / ingredient.amount
		parts.bar.caption = player.cheat_mode and {"infinity"} or util.format_number(satisfaction)
	end
end

return {
	update = updateGUI,
	lib = {
		on_init = function()
			global.gui.build_gun = global.gui.build_gun or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.build_gun or script_data
		end
	}
}
