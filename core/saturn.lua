local nativefs = require("nativefs")
local lovely = require("lovely")

Saturn = Object:extend()

function Saturn:init()
  S = self

  self:set_globals()
end

function Saturn:start_up()
  self:fetch_settings()
end

function Saturn:update(dt)

end

function Saturn:fetch_settings()
  if not nativefs.getInfo(self.MOD_PATH .. "user_settings.lua") then
    local function tableToString(tbl, indent)
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
    local settings_default = "return " .. tableToString(self.SETTINGS)
    local success, err = nativefs.write(self.MOD_PATH .. "user_settings.lua", settings_default)
    if not success then
      return error(err)
    end
  end
  local user_settings = STR_UNPACK(nativefs.read(self.MOD_PATH .. "user_settings.lua"))
  if user_settings ~= nil then
    self.SETTINGS = user_settings
  end
end

function Saturn:write_settings()
  nativefs.write(self.MOD_PATH .. "user_settings.lua", STR_PACK(self.SETTINGS))
end
