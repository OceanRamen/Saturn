-- Function to inspect a table up to a certain depth
function inspectDepth(tbl, indent, depth)
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
      str = str .. inspectDepth(v, indent + 1, (depth or 0) + 1)
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
function inspect(tbl)
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

function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == "table" then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[deepcopy(orig_key)] = deepcopy(orig_value)
    end
    setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function format_time(elapsed)
    local totalMilliseconds = elapsed * 1000
    local milliseconds = totalMilliseconds % 1000
    local totalSeconds = math.floor(totalMilliseconds / 1000)
    local seconds = totalSeconds % 60
    local totalMinutes = math.floor(totalSeconds / 60)
    local minutes = totalMinutes % 60
    local hours = math.floor(totalMinutes / 60)
    local output = ''
    if hours > 0 then
        output = output .. hours .. 'h '
    end
    if minutes > 0 then
        output = output .. minutes .. 'm '
    end
    if seconds > 0 then
        output = output .. seconds .. 's '
    end
    if milliseconds > 0 then
        output = output .. math.floor(milliseconds)  .. 'ms'
    end
    if #output == 0 then
        output = '0s'
    end
    return output
end

local function in_table(table, key)
  for k, v in pairs(table) do
    if v == key then
      return true
    end
  end
  return false
end
