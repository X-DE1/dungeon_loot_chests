# X-DE Loot

Adds a loot chest, a command to prevent spawning loot in the chest so you can save a schematic with a loot chest:
<br>
/loot enable
<br>
/loot disable

Also adds 2 functions to create loot in other chests and/or with a different dungeon type (dungeon type is optional):
<br>
add_loot("name", "description", "mod:chest", "dungeontype")
<br>
add_loot_adv("mod:node", "mod:chest", "dungeontype")

You can add a new item to the loot pool with this function:
<br>
dungeon_loot.register({name = "default:dirt", chance = 0.6, count = {2, 16}, y = {-64, 32768}, types = {"normal", "sandstone", "desert"}})

If you want to create a new dungeon type only in types = {" "} write the new dungeontype

Here are all the dungeon types that are already created:
<br>
"normal", "sandstone", "desert", "ice"

If you don't put count, the item in the loot will always be 1, if you don't put y, it will appear on any coordinate, if you don't put types, it will appear in all loot chests

X-DE Loot was created with code from [dungeon_loot](https://github.com/luanti-org/minetest_game/tree/master/mods/dungeon_loot) by [sfan5](https://github.com/sfan5)

## Installation

### ContentDB

* Content > Browse Online Content
* Search for "X-DE Loot"
* Click Install

### Manually

- Unzip the archive, rename the folder to `xde_loot` and
place it in `.../minetest/mods/`

- GNU/Linux: If you use a system-wide installation place it in `~/.minetest/mods/`.

The Luanti engine can be found at [GitHub](https://github.com/minetest/minetest).

For further information or help, see: [Installing Mods](https://wiki.luanti.org/Installing_Mods).

## License

See `LICENSE.txt`
