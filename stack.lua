Stack = {}

function Stack:new()
  local stack = { count = 0, items = {} }
  self.__index = self
  return setmetatable(stack, self)
end

function Stack:push(sort_id)
  table.insert(self.items, sort_id)
  self.count = self.count + 1
  return self -- Return self for chaining
end

function Stack:pop()
  if #self.items == 0 then
    return nil
  end
  self.count = self.count - 1
  return table.remove(self.items)
end

function Stack:popMultiple(n)
  n = math.max(0, n or 1)
  self.count = self.count - n
  local poppedItems = {}

  for i = 1, n do
    local item = self:pop()
    if item then
      table.insert(poppedItems, item)
    else
      break -- Stop if stack is empty
    end
  end
  return poppedItems
end

function Stack:peek()
  return self.items[#self.items]
end

function Stack:isEmpty()
  return #self.items == 0
end

function Stack:getSize()
  return self.count + 1
end

function Stack:validateSize()
  if self.count == #self.items then
    return true
  else
    return false
  end
end

function Stack:split(index)
  index = math.max(1, math.min(index or 1, #self.items))
  local newStack = Stack:new()
  for i = index, #self.items do
    newStack:push(self.items[i])
  end

  -- Resize original stack
  for i = #self.items, index, -1 do
    table.remove(self.items)
    self.count = self.count - 1
  end

  return newStack
end

function Stack:merge(otherStack)
  if not otherStack or not otherStack.stack or not otherStack.stack.items then
    error("Invalid stack provided for merging")
  end
  -- Add base stack Card
  self:push(otherStack.sort_id)
  for _, value in ipairs(otherStack.stack.items) do
    if type(value) ~= "number" then
      error(
        "Invalid item type in other stack: expected number, got " .. type(value)
      )
    end
    self:push(value)
  end

  -- Debugging information
  -- print("Merged stack size: " .. self:getSize())
  -- print("Merged stack items: " .. table.concat(self.items, ", "))

  return self -- Return self for chaining
end

return Stack
