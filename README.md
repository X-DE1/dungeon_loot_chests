# Dungeon loot chests 

Adds:
<br>
A chests, furnaces, bookshelf, vessel with loot, a command to prevent spawning loot in the chests, furnaces, etc so you can save a schematic with a loot chest:
<br>
/loot enable
<br>
/loot disable

Function to create a new loot item list:
<br>
register_loot("name", [[
<br>
	{
 <br>
		{name = "default:dirt", chance = 0.6, count = {2, 16}, y = {-64, 32768}, types = {"normal", "sandstone", "desert"}},
<br>
		{name = "default:book", chance = 0.7},
<br>
	}]])

Functions to create chests, furnaces, bookshelf, vessel with diferent loot:
<br>
add_loot_chest("name", "description", "mod:chest", item_list, "dungeontype")
<br>
add_loot_bookshelf("name", "description", "mod:chest", item_list, "dungeontype")
<br>
add_loot_vessel("name", "description", "mod:chest", item_list, "dungeontype")
<br>
add_loot_furnace("name", "description", "mod:chest", item_list, "dungeontype")
<br>
If you have the mod x_enchanting
<br>
add_loot_enchanting_table("name", "description", "mod:chest", item_list, "dungeontype")
<br>
add_loot_grindstone("name", "description", "mod:chest", item_list, "dungeontype")
<br>
If you have the mod s_brewing
<br>
add_loot_brewing_stand("name", "description", "mod:chest", item_list, "dungeontype")

You can add a new item to a item list with this function:
<br>
name.register({name = "default:dirt", chance = 0.6, count = {2, 16}, y = {-64, 32768}, types = {"normal", "sandstone", "desert"}})

If you want to create a new dungeon type only in types = {" "} write the new dungeontype

If you don't put count, the item in the loot will always be 1, if you don't put y, it will appear on any coordinate, if you don't put types, it will appear in all loot chests

This are all the item lists alredy created bookshelf_loot, vessel_loot, furnace_fuel_loot, furnace_dst_loot, furnace_src_loot and dungeon_loot for chests it has "normal", "sandstone", "desert", "ice" dungeontypes.

If you have the mod s_brewing: brewing_stand_dst_loot, brewing_stand_vial_loot, brewing_stand_src_loot

If you have the mod x_enchanting: enchanting_table_item_loot, enchanting_table_trade_loot, grindstone_loot

Dungeon loot chests was created with code from [dungeon_loot](https://github.com/luanti-org/minetest_game/tree/master/mods/dungeon_loot) by [sfan5](https://github.com/sfan5)

## Installation

### ContentDB

* Content > Browse Online Content
* Search for "Dungeon loot chests"
* Click Install

### Manually

- Unzip the archive, rename the folder to `dungeon_loot_chests` and
place it in `.../minetest/mods/`

- GNU/Linux: If you use a system-wide installation place it in `~/.minetest/mods/`.

The Luanti engine can be found at [GitHub](https://github.com/minetest/minetest).

For further information or help, see: [Installing Mods](https://wiki.luanti.org/Installing_Mods).

## License

See `LICENSE.txt`
