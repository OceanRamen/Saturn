local Stack = {}

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

function Stack:size()
  return self.count
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
  if not otherStack or not otherStack.items then
    return self -- Return self if other stack is invalid
  end
  for _, value in ipairs(otherStack.items) do
    self:push(value)
    self.count = self.count + 1
  end
  return self -- Return self for chaining
end

return Stack
