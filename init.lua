
loot = true

if minetest.get_modpath("dungeon_loot") then

	local function noise3d_integer(noise, pos)
		return math.abs(math.floor(noise:get_3d(pos) * 0x7fffffff))
	end

	local function random_sample(rand, list, count)
		local ret = {}
		for n = 1, count do
			local idx = rand:next(1, #list)
			table.insert(ret, list[idx])
			table.remove(list, idx)
		end
		return ret
	end

	local function populate_chest(pos, rand, dungeontype)
		--minetest.chat_send_all("chest placed at " .. minetest.pos_to_string(pos) .. " [" .. dungeontype .. "]")
		--minetest.add_node(vector.add(pos, {x=0, y=1, z=0}), {name="default:torch", param2=1})

		local item_list = dungeon_loot._internal_get_loot(pos.y, dungeontype)
		-- take random (partial) sample of all possible items
		local sample_n = math.min(#item_list, dungeon_loot.STACKS_PER_CHEST_MAX)
		item_list = random_sample(rand, item_list, sample_n)

		-- apply chances / randomized amounts and collect resulting items
		local items = {}
		for _, loot in ipairs(item_list) do
			if rand:next(0, 1000) / 1000 <= loot.chance then
				local itemdef = minetest.registered_items[loot.name]
				local amount = 1
				if loot.count ~= nil then
					amount = rand:next(loot.count[1], loot.count[2])
				end

				if not itemdef then
					minetest.log("warning", "Registered loot item " .. loot.name .. " does not exist")
				elseif itemdef.tool_capabilities then
					for n = 1, amount do
						local wear = rand:next(0.20 * 65535, 0.75 * 65535) -- 20% to 75% wear
						table.insert(items, ItemStack({name = loot.name, wear = wear}))
					end
				elseif itemdef.stack_max == 1 then
					-- not stackable, add separately
					for n = 1, amount do
						table.insert(items, loot.name)
					end
				else
					table.insert(items, ItemStack({name = loot.name, count = amount}))
				end
			end
		end

		-- place items at random places in chest
		local inv = minetest.get_meta(pos):get_inventory()
		local listsz = inv:get_size("main")
		assert(listsz >= #items)
		for _, item in ipairs(items) do
			local index = rand:next(1, listsz)
			if inv:get_stack("main", index):is_empty() then
				inv:set_stack("main", index, item)
			else
				inv:add_item("main", item) -- space occupied, just put it anywhere
			end
		end
	end
	
	function add_loot_adv(node, chest, dungeontype)
		minetest.register_abm({
			nodenames = {node},
			interval = 1,
			chance = 1,
			action = function(pos)
				if loot then
					local facedir = minetest.get_node(pos).param2
					minetest.remove_node(pos)
					minetest.add_node(pos, {name = chest, param2 = facedir})
					local noise = minetest.get_perlin(10115, 4, 0.5, 1)
					populate_chest(pos, PcgRandom(noise3d_integer(noise, pos)), dungeontype)
				end
		end,
		})
	end
	
	function add_loot(name, description, chest, dungeontype)
		minetest.register_node(minetest.get_current_modname() .. ":" .. name,
			{ description = description,
			tiles = {"default_chest_top.png", "default_chest_top.png", "default_chest_side.png", "default_chest_side.png", "default_chest_side.png", "default_chest_front.png"},
			drawtype = "normal",
			paramtype2 = "facedir",
			groups = {choppy = 2, oddly_breakable_by_hand = 2},
			sounds = default.node_sound_wood_defaults(),
		})
		minetest.register_abm({
			nodenames = {minetest.get_current_modname() .. ":" .. name},
			interval = 1,
			chance = 1,
			action = function(pos)
				if loot then
					local facedir = minetest.get_node(pos).param2
					minetest.remove_node(pos)
					minetest.add_node(pos, {name = chest, param2 = facedir})
					local noise = minetest.get_perlin(10115, 4, 0.5, 1)
					populate_chest(pos, PcgRandom(noise3d_integer(noise, pos)), dungeontype)
				end
		end,
		})
	end
	
	minetest.register_chatcommand("loot", {
		params = "<enable/disable>",
		description = "Disable or enable loot generation",
		privs = {server = true},
		func = function(name, param)
			if param == "disable" then
				loot = false
				minetest.chat_send_player(name, "Loot generation disabled")
			elseif param == "enable" then
				loot = true
				minetest.chat_send_player(name, "Loot generation enabled")
			end
		end,
	})
	
	add_loot("loot_chest", "Loot chest", "default:chest")
	add_loot("normal_loot_chest", "Normal loot chest", "default:chest", "normal")
	add_loot("sandstone_loot_chest", "Sandstone loot chest", "default:chest", "sandstone")
	add_loot("desert_loot_chest", "Desert loot chest", "default:chest", "desert")
	add_loot("ice_loot_chest", "Ice loot chest", "default:chest", "ice")
	
	if minetest.get_modpath("everness") then

		minetest.register_node("dungeon_loot_chests:everness_loot_chest",
			{ description = "Everness loot chest",
			tiles = {"everness_chest_top.png", "everness_chest_top.png", "everness_chest_side.png", "everness_chest_side.png", "everness_chest_side.png", "everness_chest_front.png"},
			drawtype = "normal",
			paramtype2 = "facedir",
			groups = {choppy = 2, oddly_breakable_by_hand = 2},
			sounds = default.node_sound_wood_defaults(),
		})
		
		add_loot_adv("dungeon_loot_chests:everness_loot_chest", "everness:chest")

	end
	
end
