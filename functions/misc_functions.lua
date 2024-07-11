funcs = {}

 function funcs.requireWithNFS(modulePath)
  -- Read the file content
  local content, err = nativefs.read(modulePath)
  if not content then
    error("Error reading module file: " .. tostring(err))
  end

  -- Load the content as a chunk
  local chunk, loadErr = load(content, modulePath)
  if not chunk then
    error("Error loading module chunk: " .. tostring(loadErr))
  end

  -- Execute the chunk and return the module
  local result = chunk()
  return result
end

-- Function to convert table to a string in Lua code format
function funcs.tableToString(tbl, indent)
  indent = indent or 0
  local result = "{\n"
  local padding = string.rep("  ", indent + 1)

  for k, v in pairs(tbl) do
    if type(k) == "string" then
      k = '"' .. k .. '"'
    end

    if type(v) == "table" then
      result = result .. padding .. "[" .. k .. "] = " .. tableToString(v, indent + 1) .. ",\n"
    else
      result = result .. padding .. "[" .. k .. "] = " .. tostring(v) .. ",\n"
    end
  end

  result = result .. string.rep("  ", indent) .. "}"
  return result
end

return funcs