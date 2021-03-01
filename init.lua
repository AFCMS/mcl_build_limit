local c_void = minetest.get_content_id("mcl_core:void")

local limit_overworld = mcl_vars.mg_overworld_max_official+1
local limit_end = mcl_vars.mg_end_max_official+1


local function set_layers(data, area, content_id, check, min, max, minp, maxp, lvm_used, pr)
	if (maxp.y >= min and minp.y <= max) then
		for y = math.max(min, minp.y), math.min(max, maxp.y) do
			for x = minp.x, maxp.x do
				for z = minp.z, maxp.z do
					local p_pos = area:index(x, y, z)
					if check then
						if type(check) == "function" and check({x=x,y=y,z=z}, data[p_pos], pr) then
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

mcl_mapgen_core.register_generator("mcl_build_limit", function(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	local lvm_used = false
	-- Void at the top of the Overworld
	lvm_used = set_layers(data, area, c_void, nil, limit_overworld, limit_overworld, minp, maxp, lvm_used)
	-- Void at the top of the End
	lvm_used = set_layers(data, area, c_void, nil, limit_end, limit_end, minp, maxp, lvm_used)
	return lvm_used
end, nil, 1, false)


