local c_void = minetest.get_content_id("mcl_core:void")

local limit_overworld = mcl_vars.mg_overworld_max_official+1
local limit_end = mcl_vars.mg_end_max_official+1

minetest.register_on_generated(function(minp, maxp, seed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data(lvm_buffer)
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local lvm_used = false

	-- Generate basic layer-based nodes: void, bedrock, realm barrier, lava seas, etc.
	-- Also perform some basic node replacements.

	-- Helper function to set all nodes in the layers between min and max.
	-- content_id: Node to set
	-- check: optional.
	--	If content_id, node will be set only if it is equal to check.
	--	If function(pos_to_check, content_id_at_this_pos), will set node only if returns true.
	-- min, max: Minimum and maximum Y levels of the layers to set
	-- minp, maxp: minp, maxp of the on_generated
	-- lvm_used: Set to true if any node in this on_generated has been set before.
	--
	-- returns true if any node was set and lvm_used otherwise
	local function set_layers(content_id, check, min, max, minp, maxp, lvm_used)
		if (maxp.y >= min and minp.y <= max) then
			for y = math.max(min, minp.y), math.min(max, maxp.y) do
				for x = minp.x, maxp.x do
					for z = minp.z, maxp.z do
						local p_pos = area:index(x, y, z)
						if check then
							if type(check) == "function" and check({x=x,y=y,z=z}, data[p_pos]) then
								data[p_pos] = content_id
								lvm_used = true
							elseif check == data[p_pos] then
								data[p_pos] = content_id
								lvm_used = true
							end
						else
							data[p_pos] = content_id
							lvm_used = true
						end
					end
				end
			end
		end
		return lvm_used
	end

	-- Void at the top of the Overworld
	lvm_used = set_layers(c_void, nil, limit_overworld, limit_overworld, minp, maxp, lvm_used)
	-- Void at the top of the End
	lvm_used = set_layers(c_void, nil, limit_end, limit_end, minp, maxp, lvm_used)
	
	if lvm_used then
		vm:set_data(data)
		--vm:calc_lighting(nil, nil, shadow)
		vm:write_to_map()
	end
end)