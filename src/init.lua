local MV_CORE <const> = "mv_core"

local function init(path)
    path = path:gsub('%.', '/')
    local module_path <const> = ("%s.lua"):format(path)
    local module_file <const> = LoadResourceFile(MV_CORE, module_path)
    if not module_file then
        error("^1Impossible d'initialiser le module : "..path.."^0", 2)
    end

    local module <const> = load(module_file)()
    return module
end

local mv <const> = setmetatable({
    name = MV_CORE,
    service = (IsDuplicityVersion() and "server") or "client",
    void = function() end,
    await = Citizen.Await,
    locale = GetConvar("mira:locale", "en"),
    mode = GetConvar("mira:mode", "dev"),
    env = MV_CORE,
}, {
    ---@todo implement, need to look if metamethods are useful ? if not, remove metatable
    ---@todo Maybe useful to add exports auto register on mv.__index is function ?
})

_ENV.mv = mv

init 'imports.require.shared'

require.alias {
    { "class-builder", "imports.class.shared" },
}