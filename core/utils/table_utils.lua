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

function deepCopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == "table" then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[deepCopy(orig_key)] = deepCopy(orig_value)
    end
    setmetatable(copy, deepCopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end
