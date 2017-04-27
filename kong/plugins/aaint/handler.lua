local plugin = require("kong.plugins.base_plugin"):extend()
local access = require "kong.plugins.aaint.access"

function plugin:new()
  plugin.super.new(self, "aaint") 
end

function plugin:access(plugin_conf)
  plugin.super.access(self)
  access.execute(plugin_conf)
end 

plugin.PRIORITY = 900 --after OAuth plugin 1000, so headers should have been setup
return plugin
