Timer = {}
Timer.__index = Timer

function Timer:new(callback)
  local obj = {
    callback = callback or nil,
    elapsed = 0,
    running = false,
    disp = "",
  }
  setmetatable(obj, Timer)
  return obj
end

function Timer:start()
  self.elapsed = 0
  self.running = true
end

function Timer:stop()
  self.running = false
  if self.callback then
    self.callback(self.elapsed)
  end
end

function Timer:update(dt)
  if self.running then
    self.elapsed = self.elapsed + dt
  end
end

function Timer:reset()
  self.elapsed = 0
end

-- Convert elapsed time to hours:minutes:seconds:milliseconds
function Timer:getFormattedTime()
  local totalMilliseconds = self.elapsed * 1000
  local milliseconds = totalMilliseconds % 1000
  local totalSeconds = math.floor(totalMilliseconds / 1000)
  local seconds = totalSeconds % 60
  local totalMinutes = math.floor(totalSeconds / 60)
  local minutes = totalMinutes % 60
  local hours = math.floor(totalMinutes / 60)

  return string.format("%02d:%02d:%02d:%03d", hours, minutes, seconds, milliseconds)
end

return Timer