-- Hyprland Lua Configuration
-- Entry point

-- Load modules
require("env")
require("monitors")
require("input")
require("look")
require("rules")
require("binds")
require("plugins")
require("autostart")

-- Custom configurations
-- Note: Lua doesn't have a direct 'source *' equivalent easily, 
-- but you can manually require files here if you add any to custom/
