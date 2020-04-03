local M = {}

local created_files = {}

function file_exists(file_path)
    local file = io.open(file_path, "rb")
    if file then
        file:close()
        return true
    end
    return false
end

-- https://pico-8.fandom.com/wiki/Lua
function filter_p8_line(line)
    local filtered_line = line:gsub("!=", "~=")
    return filtered_line
end

function find_candidate_paths(module_ref)
    local module_lua_path = os.getenv('P8_CART_PATH') or "carts/?.p8"

    local module_candidates = {}
    for path in string.gmatch(module_lua_path, "[^;]+") do
        local candidate = string.gsub(path, "%?", module_ref)
        table.insert(module_candidates, candidate)
    end

    return module_candidates
end

function find_module_file(module_ref)
    for _, candidate in ipairs(find_candidate_paths(module_ref)) do
        if file_exists(candidate) then
            return candidate
        end
    end

    if not module_file_to_load then
        error("Could not find module " .. module_ref)
    end
end

function create_lua_module(module_file_to_load)
    local output_filename = module_file_to_load:gsub("%.p8$", "")
    local out = io.open(output_filename .. ".lua", "wb")
    local in_lua = false
    for line in io.lines(module_file_to_load) do
        if in_lua and line == "__gfx__" then
            in_lua = false
        end
        
        if in_lua then
            out:write(filter_p8_line(line))
            out:write('\n')
        elseif line == "__lua__" then
            in_lua = true
        end
    end
    out:close()
    table.insert(created_files, output_filename .. ".lua")

    return output_filename
end

function M.import_globals(module_ref)
    local lua_module = create_lua_module(find_module_file(module_ref))
    require(lua_module)
end

function M.cleanup()
    for _, filename in ipairs(created_files) do
        if file_exists(filename) then
            os.remove(filename)
        end
    end
end

return M
