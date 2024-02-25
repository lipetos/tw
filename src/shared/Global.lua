local Global = {}

-- keep in mind that this is a costy function, shouldnt run constantly
function Global.path(parent: Instance, path: string): Instance?
    local paths = string.split(path, "/")
    local inst = parent

    for i,v in paths do
        local child = inst:FindFirstChild(v)

        if not child then
            error(`Failed to find {v} in {inst:GetFullName()} ( path: {path} )`, 2)
        end

        inst = child
    end

    return inst
end

function Global.path_wait(parent: Instance, path: string): Instance?
    local paths = string.split(path, "/")
    local inst = parent

    for i,v in paths do
        local child = inst:WaitForChild(v)

        if not child then
            error(`Failed to find {v} in {inst:GetFullName()} ( path: {path} )`, 2)
        end

        inst = child
    end

    return inst
end


return Global