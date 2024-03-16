local query = {
    methods = {}
}

------------

function query.get(hitbox: Part, overlapParams: OverlapParams?): {BasePart}
    local shape = hitbox.Shape
    local method = query.methods[shape]

    if not method then
        method = query.methods.other
    end

    return method(hitbox, overlapParams)
end

--

query.methods.other = function(hitbox: Part, overlapParams: OverlapParams?): {BasePart}
    return workspace:GetPartsInPart(hitbox, overlapParams)
end

query.methods[Enum.PartType.Block] = function(hitbox: Part, overlapParams: OverlapParams?): {BasePart}
    return workspace:GetPartBoundsInBox(hitbox.CFrame, hitbox.Size, overlapParams)
end

query.methods[Enum.PartType.Ball] = function(hitbox: Part, overlapParams: OverlapParams?): {BasePart}
    local diameter = (hitbox.Size.X + hitbox.Size.Z) / 2

    return workspace:GetPartBoundsInRadius(hitbox.Position, diameter / 2, overlapParams)
end

------------

return query