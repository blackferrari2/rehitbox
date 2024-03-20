local query = require(script.query)

local rehitbox = {}
rehitbox.__index = rehitbox

------------

type self = {
	hitboxes: {Part},
	filter: OverlapParams,
}

export type touches = {
	[BasePart]: Part
}

export type rehitbox = typeof(setmetatable({} :: self, rehitbox))

------------

local priorityAttribute = "rehitboxPriority"

------------

-- warning: filter doesnt support whitelist yet. if you set it to that, itll break.
function rehitbox.new(): rehitbox
	local self = {
		hitboxes = {},
		filter = OverlapParams.new(),
	}

	setmetatable(self, rehitbox)

	self.filter.FilterType = Enum.RaycastFilterType.Exclude

	return self
end

-- `hitbox` should be a temporary part instanced on the spot. Do not cache
-- `priority` is the order of getTouchingParts. Higher priority will be scanned first.
-- note: different shapes of Part are supported
-- i.e: spheres will use GetPartsBoundInRadius
function rehitbox.add(self: rehitbox, hitbox: Part, priority: number?)
	table.insert(self.hitboxes, hitbox)
	self.filter:AddToFilter(hitbox)

	hitbox:SetAttribute(priorityAttribute)

	table.sort(self.hitboxes, function(part1, part2)
		local priority1 = part1:GetAttribute(priorityAttribute)
		local priority2 = part2:GetAttribute(priorityAttribute)

		return priority1 > priority2
	end)
end

-- this returns a `touches` list.
-- its a dictionary where
	-- keys: the parts u hit
	-- values: the hitbox that hit it
-- note: hitboxes cannot be hit by themselves or other hitboxes from same group
function rehitbox.getTouchingParts(self: rehitbox): touches
	local touches = {}

	for _, hitbox in ipairs(self.hitboxes) do
		local parts = query.get(hitbox, self.filter)

		for _, part in pairs(parts) do
			-- ignore stuff already hit
			if touches[part] then
				continue
			end

			touches[part] = hitbox
		end
	end

	return touches
end

function rehitbox.isTouching(touches: touches): boolean
	for _, touch in pairs(touches) do
		return true
	end

	return false
end

function rehitbox.isTouchingA(part: BasePart, touches: touches): boolean
	return touches[part] ~= nil
end

function rehitbox.isTouchingOneOfThe(parts: {BasePart}, touches: touches): boolean
	for _, part in pairs(parts) do
		if touches[part] then
			return true
		end
	end

	return false
end

function rehitbox.isTouchingAllThe(parts: {BasePart}, touches: touches): boolean
	for _, part in pairs(parts) do
		if not touches[part] then
			return false
		end
	end

	return true
end

function rehitbox.destroy(self: rehitbox)
	for _, hitbox in pairs(self.hitboxes) do
		hitbox:Destroy()
	end

	local setmetatable: any = setmetatable
	setmetatable(self, nil)
end

------------

return rehitbox