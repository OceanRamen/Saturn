-- Saturn.TOOLS.LOGGER Module
local Logger = {}

local LogLevel = {
  INFO = "INFO",
  WARNING = "WARNING",
  ERROR = "ERROR",
}

local function getTimestamp()
  return os.date("%Y-%m-%d %H:%M:%S")
end

-- Logging function
local function log(level, message)
  if not LogLevel[level] then
    error("Invalid log level: " .. tostring(level))
  end
  local timestamp = getTimestamp()
  local logMessage = string.format("[%s] [%s] [%s] %s", "SATURN", timestamp, level, message)
  print(logMessage)
end

function Logger.logInfo(message)
  log(LogLevel.INFO, message)
end

function Logger.logWarning(message)
  log(LogLevel.WARNING, message)
end

function Logger.logError(message)
  log(LogLevel.ERROR, message)
end

return Logger
