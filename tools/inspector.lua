-- Helper.lua
local Helper = {}

-- Function to inspect a table up to a certain depth
function Helper.inspectDepth(tbl, indent, depth)
  if depth and depth > 5 then
    return "Depth limit reached"
  end

  if type(tbl) ~= "table" then
    return "Not a table"
  end

  local str = ""
  indent = indent or 0

  for k, v in pairs(tbl) do
    local formatting = string.rep("  ", indent) .. tostring(k) .. ": "
    if type(v) == "table" then
      str = str .. formatting .. "\n"
      str = str .. Helper.inspectDepth(v, indent + 1, (depth or 0) + 1)
    elseif type(v) == "function" then
      str = str .. formatting .. "function\n"
    elseif type(v) == "boolean" then
      str = str .. formatting .. tostring(v) .. "\n"
    else
      str = str .. formatting .. tostring(v) .. "\n"
    end
  end

  return str
end

--- Inspects a table and returns its string representation.
-- @param tbl The table to inspect.
-- @return A string representation of the table.
function Helper.inspect(tbl)
  if type(tbl) ~= "table" then
    return "Not a table"
  end

  local str = ""
  for k, v in pairs(tbl) do
    local valueStr = type(v) == "table" and "table" or tostring(v)
    str = str .. tostring(k) .. ": " .. valueStr .. "\n"
  end

  return str
end

return Helper
