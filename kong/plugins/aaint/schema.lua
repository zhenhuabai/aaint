return {
  no_consumer = false, -- this plugin is available on APIs as well as on Consumers,
  fields = {
    -- defailt AA server, a faked one
    aasvr = {type = "string", default = "http://10.245.247.180:7612/authorize"}
  },
  self_check = function(schema, plugin_t, dao, is_updating)
    -- perform any custom verification
    return true
  end
}
