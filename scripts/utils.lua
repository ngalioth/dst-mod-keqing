-- Use this function to fan out a search for a point that meets a condition.
-- If your condition is basically "walkable ground" use FindWalkableOffset instead.
-- test_fn takes a parameter "offset" which is check_angle*radius.
local function FindValidPositionByFan(start_angle, radius, attempts, test_fn)
	attempts = attempts or 8

	local attempt_angle = TWOPI / attempts
	local tmp_angles = {}
	for i = 0, attempts - 1 do
		local a = i * attempt_angle
		table.insert(tmp_angles, a > PI and a - TWOPI or a)
	end

	-- Make the angles fan out from the original point
	local angles = {}
	local iend = math.floor(attempts / 2)
	for i = 1, iend do
		table.insert(angles, tmp_angles[i])
		table.insert(angles, tmp_angles[attempts - i + 1])
	end
	if iend * 2 < attempts then
		table.insert(angles, tmp_angles[iend + 1])
	end

	for i, v in ipairs(angles) do
		local check_angle = start_angle + v
		if check_angle > TWOPI then
			check_angle = check_angle - TWOPI
		end
		local offset = Vector3(radius * math.cos(check_angle), 0, -radius * math.sin(check_angle))
		if test_fn(offset) then
			return offset, check_angle, i > 1 --deflected if not first try
		end
	end
end
-- This function fans out a search from a starting position/direction and looks for a walkable
-- position, and returns the valid offset, valid angle and whether the original angle was obstructed.
-- start_angle is in radians
local function FindWalkableOffset(
	position,
	start_angle,
	radius,
	attempts,
	check_los,
	ignore_walls,
	customcheckfn,
	allow_water,
	allow_boats
)
	return FindValidPositionByFan(start_angle, radius, attempts, function(offset)
		local x = position.x + offset.x
		local y = position.y + offset.y
		local z = position.z + offset.z
		return (
			TheWorld.Map:IsAboveGroundAtPoint(x, y, z, allow_water)
			or (allow_boats and TheWorld.Map:GetPlatformAtPoint(x, z) ~= nil)
		)
			and (not check_los or TheWorld.Pathfinder:IsClear(
				position.x,
				position.y,
				position.z,
				x,
				y,
				z,
				{ ignorewalls = ignore_walls ~= false, ignorecreep = true, allowocean = allow_water }
			))
			and (customcheckfn == nil or customcheckfn(Vector3(x, y, z)))
	end)
end
