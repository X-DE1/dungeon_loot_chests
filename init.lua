
loot = true

if minetest.get_modpath("dungeon_loot") then

	function register_loot(name, loot)
	
		loadstring([[
		
		]] .. name .. [[ = {}

		]] .. name .. [[.registered_loot = ]] .. loot .. [[

		function ]] .. name .. [[.register(t)
			if t.name ~= nil then
				t = {t} -- single entry
			end
			for _, loot in ipairs(t) do
				table.insert(]] .. name .. [[.registered_loot, loot)
			end
		end

		function ]] .. name .. [[._internal_get_loot(pos_y, dungeontype)
			-- filter by y pos and type
			local ret = {}
			for _, l in ipairs(]] .. name .. [[.registered_loot) do
				if l.y == nil or (pos_y >= l.y[1] and pos_y <= l.y[2]) then
					if l.types == nil or table.indexof(l.types, dungeontype) ~= -1 then
						table.insert(ret, l)
					end
				end
			end
			return ret
		end]])()
	end

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

	local function populate(pos, rand, meta, loot, dungeontype)
		--minetest.chat_send_all("chest placed at " .. minetest.pos_to_string(pos) .. " [" .. dungeontype .. "]")
		--minetest.add_node(vector.add(pos, {x=0, y=1, z=0}), {name="default:torch", param2=1})

		local item_list = loot._internal_get_loot(pos.y, dungeontype)
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
		local listsz = inv:get_size(meta)
		--assert(listsz >= #items)
		for _, item in ipairs(items) do
			local index = rand:next(1, listsz)
			if inv:get_stack(meta, index):is_empty() then
				inv:set_stack(meta, index, item)
			else
				inv:add_item(meta, item) -- space occupied, just put it anywhere
			end
		end
	end
	
	function add_loot_chest(name, description, chest, loot, dungeontype)
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
					populate(pos, PcgRandom(noise3d_integer(noise, pos)), "main", loot, dungeontype)
				end
		end,
		})
	end
	
	function add_loot_bookshelf(name, description, chest, loot, dungeontype)
		minetest.register_node(minetest.get_current_modname() .. ":" .. name,
			{ description = description,
			tiles = {"default_wood.png", "default_wood.png", "default_wood.png", "default_wood.png", "default_bookshelf.png", "default_bookshelf.png"},
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
					populate(pos, PcgRandom(noise3d_integer(noise, pos)), "books", loot, dungeontype)
				end
		end,
		})
	end
	
	function add_loot_vessel(name, description, chest, loot, dungeontype)
		minetest.register_node(minetest.get_current_modname() .. ":" .. name,
			{ description = description,
			tiles = {"default_wood.png", "default_wood.png", "default_wood.png", "default_wood.png", "vessels_shelf.png", "vessels_shelf.png"},
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
					populate(pos, PcgRandom(noise3d_integer(noise, pos)), "vessels", loot, dungeontype)
				end
		end,
		})
	end
	
	function add_loot_furnace(name, description, chest, loot1, loot2, loot3, dungeontype)
		minetest.register_node(minetest.get_current_modname() .. ":" .. name,
			{ description = description,
			tiles = {"default_furnace_top.png", "default_furnace_top.png", "default_furnace_side.png", "default_furnace_side.png", "default_furnace_side.png", "default_furnace_front.png"},
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
					if math.random(2) == 2 then
						populate(pos, PcgRandom(noise3d_integer(noise, pos)), "dst", loot2, dungeontype)
						populate(pos, PcgRandom(noise3d_integer(noise, pos)), "fuel", loot1, dungeontype)
					else
						populate(pos, PcgRandom(noise3d_integer(noise, pos)), "src", loot3, dungeontype)
						populate(pos, PcgRandom(noise3d_integer(noise, pos)), "dst", loot2, dungeontype)
					end
				end
		end,
		})
	end
	
	minetest.register_chatcommand("loot", {
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
	
	add_loot_chest("loot_chest", "Loot chest", "default:chest", dungeon_loot)
	add_loot_chest("normal_loot_chest", "Normal loot chest", "default:chest", dungeon_loot, "normal")
	add_loot_chest("sandstone_loot_chest", "Sandstone loot chest", "default:chest", dungeon_loot, "sandstone")
	add_loot_chest("desert_loot_chest", "Desert loot chest", "default:chest", dungeon_loot, "desert")
	add_loot_chest("ice_loot_chest", "Ice loot chest", "default:chest", dungeon_loot, "ice")

	register_loot("bookshelf_loot", [[
	{
		{name = "default:book", chance = 0.9},
		{name = "default:book", chance = 0.7},
		{name = "default:book", chance = 0.5},
		{name = "default:book", chance = 0.3},
		{name = "default:book", chance = 0.1},
	}]])
	add_loot_bookshelf("loot_bookshelf", "Loot bookshelf", "default:bookshelf", bookshelf_loot)
	
	register_loot("vessel_loot", [[
	{
		{name = "vessels:glass_bottle", chance = 0.9},
		{name = "vessels:glass_bottle", chance = 0.9},
		{name = "vessels:steel_bottle", chance = 0.9},
		{name = "vessels:steel_bottle", chance = 0.9},
		{name = "vessels:drinking_glass", chance = 0.9},
		{name = "vessels:drinking_glass", chance = 0.9},
	}]])
	add_loot_vessel("loot_vessel", "Loot vessel", "vessels:shelf", vessel_loot)
	
	register_loot("furnace_fuel_loot", [[
	{
		{name = "default:bucket_lava", chance = 0.1},
		{name = "default:coalblock", chance = 0.1},
		{name = "default:coal_lump", chance = 0.1},
		{name = "default:wood", chance = 0.1},
		{name = "default:junglewood", chance = 0.1},
		{name = "default:pine_wood", chance = 0.1},
		{name = "default:aspen_wood", chance = 0.1},
		{name = "default:acacia_wood", chance = 0.1},
		{name = "default:tree", chance = 0.1},
		{name = "default:jungletree", chance = 0.1},
		{name = "default:pine_tree", chance = 0.1},
		{name = "default:aspen_tree", chance = 0.1},
		{name = "default:acacia_tree", chance = 0.1},
	}]])
	register_loot("furnace_dst_loot", [[
	{
		{name = "farming:bread", chance = 0.1},
		{name = "default:clay_brick", chance = 0.1},
		{name = "default:steel_ingot", chance = 0.1},
		{name = "default:tin_ingot", chance = 0.1},
		{name = "default:copper_ingot", chance = 0.1},
		{name = "default:gold_ingot", chance = 0.1},
	}]])
	register_loot("furnace_src_loot", [[
	{
		{name = "farming:flour", chance = 0.1},
		{name = "default:clay_lump", chance = 0.1},
		{name = "default:iron_lump", chance = 0.1},
		{name = "default:tin_lump", chance = 0.1},
		{name = "default:copper_lump", chance = 0.1},
		{name = "default:gold_lump", chance = 0.1},
	}]])
	add_loot_furnace("loot_furnace", "Loot furnace", "default:furnace", furnace_fuel_loot, furnace_dst_loot, furnace_src_loot)
	
	if minetest.get_modpath("s_brewing") then
		function add_loot_brewing_stand(name, description, chest, loot1, loot2, loot3, dungeontype)
			minetest.register_node(minetest.get_current_modname() .. ":" .. name,
				{ description = description,
				tiles = {"default_wood.png", "default_wood.png", "default_wood.png", "default_wood.png", "default_wood.png", "default_wood.png"},
				inventory_image = "s_brewing_stand.png",
				wield_image = "s_brewing_stand.png",
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
						if math.random(2) == 2 then
							populate(pos, PcgRandom(noise3d_integer(noise, pos)), "dst", loot1, dungeontype)
							populate(pos, PcgRandom(noise3d_integer(noise, pos)), "vial", loot2, dungeontype)
						else
							populate(pos, PcgRandom(noise3d_integer(noise, pos)), "dst", loot1, dungeontype)
							populate(pos, PcgRandom(noise3d_integer(noise, pos)), "src", loot3, dungeontype)
						end
					end
			end,
			})
		end
		register_loot("brewing_stand_dst_loot", [[
		{
			{name = "s_potions_default:water_brething", chance = 0.1},
			{name = "s_potions_default:invulnerability", chance = 0.1},
			{name = "s_potions_default:jump", chance = 0.1},
			{name = "s_potions_default:gravity", chance = 0.1},
			{name = "s_potions_default:speed", chance = 0.1},
		}]])
		register_loot("brewing_stand_vial_loot", [[
		{
			{name = "vessels:glass_bottle", chance = 0.1},
		}]])
		register_loot("brewing_stand_src_loot", [[
		{
			{name = "default:steel_ingot", chance = 0.1},
			{name = "default:tin_ingot", chance = 0.1},
			{name = "default:copper_ingot", chance = 0.1},
			{name = "default:gold_ingot", chance = 0.1},
			{name = "default:diamond", chance = 0.1},
			{name = "default:obsidian_glass", chance = 0.1},
		}]])
		add_loot_brewing_stand("loot_brewing_stand", "Loot brewing stand", "s_brewing:stand", brewing_stand_dst_loot, brewing_stand_vial_loot, brewing_stand_src_loot)
	end
	
	if minetest.get_modpath("x_enchanting") then
		function add_loot_enchanting_table(name, description, chest, loot1, loot2, dungeontype)
			minetest.register_node(minetest.get_current_modname() .. ":" .. name,
				{ description = description,
				tiles = {"default_diamond_block.png", "default_diamond_block.png", "default_obsidian.png", "default_obsidian.png", "default_obsidian.png", "default_obsidian.png"},
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
						populate(pos, PcgRandom(noise3d_integer(noise, pos)), "item", loot1, dungeontype)
						populate(pos, PcgRandom(noise3d_integer(noise, pos)), "trade", loot2, dungeontype)
					end
			end,
			})
		end

		register_loot("enchanting_table_item_loot", [[
		{
			{name = "default:sword_diamond", chance = 0.1},
			{name = "default:sword_mese", chance = 0.1},
			{name = "default:sword_steel", chance = 0.1},
			{name = "default:pick_diamond", chance = 0.1},
			{name = "default:pick_mese", chance = 0.1},
			{name = "default:pick_steel", chance = 0.1},
			{name = "default:axe_diamond", chance = 0.1},
			{name = "default:axe_mese", chance = 0.1},
			{name = "default:axe_steel", chance = 0.1},
			{name = "default:shovel_diamond", chance = 0.1},
			{name = "default:shovel_mese", chance = 0.1},
			{name = "default:shovel_steel", chance = 0.1},
		}]])
		register_loot("enchanting_table_trade_loot", [[
		{
			{name = "default:mese_crystal", chance = 0.1, count = {1, 3}},
		}]])
		add_loot_enchanting_table("loot_enchanting_table", "Loot enchanting table", "x_enchanting:table", enchanting_table_item_loot, enchanting_table_trade_loot)
	
	
	
		function add_loot_grindstone(name, description, chest, loot, dungeontype)
			minetest.register_node(minetest.get_current_modname() .. ":" .. name,
				{ description = description,
				tiles = {"default_wood.png", "default_wood.png", "default_wood.png", "default_wood.png", "default_wood.png", "default_wood.png"},
				inventory_image = "x_enchanting_grindstone_item.png",
				wield_image = "x_enchanting_grindstone_item.png",
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
						populate(pos, PcgRandom(noise3d_integer(noise, pos)), "result", loot, dungeontype)
					end
			end,
			})
		end
		
		register_loot("grindstone_loot", [[
		{
			{name = "default:sword_diamond", chance = 0.1},
			{name = "default:sword_mese", chance = 0.1},
			{name = "default:sword_steel", chance = 0.1},
			{name = "default:pick_diamond", chance = 0.1},
			{name = "default:pick_mese", chance = 0.1},
			{name = "default:pick_steel", chance = 0.1},
			{name = "default:axe_diamond", chance = 0.1},
			{name = "default:axe_mese", chance = 0.1},
			{name = "default:axe_steel", chance = 0.1},
			{name = "default:shovel_diamond", chance = 0.1},
			{name = "default:shovel_mese", chance = 0.1},
			{name = "default:shovel_steel", chance = 0.1},
		}]])
		add_loot_grindstone("loot_grindstone", "Loot grindstone", "x_enchanting:grindstone", grindstone_loot)
	
	end
end
