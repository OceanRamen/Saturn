function viewJkr(_file)
  local file = io.open(_file)
  local content
  if file then
    content = file:read()
    content = love.data.compress("string", "deflate", content, 1)
  end
  print("File: " .. file .. "\nContent: " .. content)
end
