local MV_CORE <const> = "mv_core"
local cache <const> = {}
local decode <const> = json.decode
local LoadResourceFile <const> = LoadResourceFile

--[[
    Todo in this file:
    - init debugger mode with mv.mode on 'dev'
    - init locale system
--]]

---@param path string
---@param isJsonFile? boolean
---@return unknown
local function init(path, isJsonFile)
    path = path:gsub('%.', '/')
    local filePath <const> = isJsonFile and ("%s.json"):format(path) or ("%s.lua"):format(path)

    if cache[filePath] then
        return cache[filePath]
    end
    local fileContent <const> = LoadResourceFile(MV_CORE, filePath)
    if not fileContent then
        error("^1Error loading file file : "..path.."^0", 2)
    end
    if isJsonFile then
        local data <const> = decode(fileContent)
        if not data then
            error("^1Error decoding json file : "..path.."^0", 2)
        end

        cache[filePath] = data or true
        return data
    end

    local fn <const>, err <const> = load(fileContent)
    if not fn or err then
        error("^1Error loading module : "..path.."^0", 2)
    end

    local module <const> = fn()
    cache[filePath] = module or true
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