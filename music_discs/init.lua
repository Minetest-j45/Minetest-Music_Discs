local craftitems = {
    {"cat", "cat_disc.png", "cat.ogg"},
    {"mellohi", "mellohi_disc.png", "mellohi.ogg"},
    {"blocks", "blocks_disc.png", "blocks.ogg"},
    {"chirp", "chirp_disc.png", "chirp.ogg"},
    {"far", "far_disc.png", "far.ogg"},
    {"mall", "mall_disc.png", "mall.ogg"},
    {"stal", "stal_disc.png", "stal.ogg"},
    {"strad", "strad_disc.png", "strad.ogg"},
    {"ward", "ward_disc.png", "ward.ogg"},
    {"13", "13_disc.png", "13.ogg"},
    {"11", "11_disc.png", "11.ogg"},
    {"himbeer", "himbeer_disc.png", "himbeer.ogg"},
    {"olliy", "olliy_disc.png", "olliy.ogg"},
}

for _, def in pairs(craftitems) do
    local name = "music_discs:" .. string.lower(def[1]):gsub("+", "p"):gsub(" ", "_")
    minetest.register_craftitem(name, {
        description = def[1] .. " disc",
        inventory_image = def[2],
        stack_max = 1,
    })
end

minetest.register_node("music_discs:jukebox",{
    description = "Play some music and chill.",
    tiles = {"jukebox.png"},
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        if not itemstack:get_name():find("music_discs:", nil, true) then return end
        local disc = itemstack:get_name():gsub("music_discs:", "")
        local abort = true
        for _, def in pairs(craftitems) do
            if def[1] == disc then
                abort = false
            end
        end
        if abort then return end
        minetest.sound_play(disc, {
            pos = pos,
            max_hear_distance = 21,
            gain = 4.0,
        })
    end,
})

minetest.register_craft({
	output = "music_discs:jukebox",
	recipe = {
		{"default:diamond", "default:diamond", "default:diamond"},
		{"default:wood", "default:obsidian", "default:wood"},
		{"default:wood", "default:wood", "default:wood"}
	}
})

disc_drops = {}
for _, def in pairs(craftitems) do
	local name = "music_discs:" .. string.lower(def[1]):gsub("+", "p"):gsub(" ", "_")
	table.insert(disc_drops, {name = name, chance = #craftitems * #craftitems, min = 1, max = 1})
end

mobs:register_mob("music_discs:disc_monster", {
    type = "monster",
    hp_min = 33,
    hp_max = 42,
    armor = 73,
    passive = false,
    attack_monsters = false,
    attack_npcs = false,
    attack_animals = false,
    attack_players = true,
    attack_type = "dogfight",
	damage = 4,
	reach = 3,
    jump_height = 1.5,
    step_height = 1.1,
    follow = {"music_discs:jukebox"},
    pushable = true,
    view_range = 10,
    knock_back = true,
    fear_height = 2,
    fall_damage = true,
    lava_damage = 5,
    float = 1,
    drops = disc_drops,
    collisionbox = {-0.56, -0.2, -0.56, 0.56, 1.2, 0.56},
    visual = "mesh",
    mesh = "disc_monster.x",
    textures = {
        {"disc_monster.png"}
    },
})

minetest.register_craftitem("music_discs:disc_monster_egg",{
    description = "Disc monster egg",
    inventory_image = "disc_monster_egg.png",
    on_place = function(itemstack, placer, pointed_thing)
        local egg_pointed = minetest.get_pointed_thing_position(pointed_thing, pointed_thing.above)
        minetest.add_entity(egg_pointed, "music_discs:disc_monster")
        itemstack:take_item()
        return itemstack
    end,
})

minetest.register_node("music_discs:disc_monster_spawner", {
	description = "Disc monster spawner",
	drawtype = "allfaces_optional",
	tiles = {"mobspawn_cage_top.png", "mobspawn_cage_bottom.png", "mobspawn_cage_side.png"},
	is_ground_content = false,
	groups = {cracky=1},
	light_source = 3,
	paramtype = "light",
	use_texture_alpha = true,
	sunlight_propagates = true,
})
	
minetest.register_abm({
	label = "Disc monster spawner",
	nodenames = {"music_discs:disc_monster_spawner"},
	interval = 30,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local npos = {x=pos.x + math.random(-3,3), y=pos.y + 1, z=pos.z + math.random(-3,3)}
		if (minetest.get_node_light(npos) < 10) then
			local count = 0
			for _,ent in pairs(minetest.get_objects_inside_radius(pos, 6)) do
				count = count + 1
			end
			if count < 7 then
				minetest.add_entity(npos, "music_discs:disc_monster")
			end
		end
	end,
})
