-- require http = "resty.http"
local string_find = string.find
local _M = {}
local responses = require "kong.tools.responses"
local req_get_headers = ngx.req.get_headers

function _M.execute(conf)
  if conf.aasvr then
    ngx.log(ngx.DEBUG, "print header info")
    local header = ngx.req.get_headers()
    for k,v in pairs(header) do
        ngx.log(ngx.DEBUG, "\n"..k..":"..v.."\n")
    end
    local username = ngx.req.get_headers()["X-Consumer-Username"]
    local userid = ngx.req.get_headers()["x-authenticated-userid"]
    local scope = ngx.req.get_headers()["x-authenticated-scope"]
    local requestedapi = ngx.var.uri
    ngx.log(ngx.INFO, "Access aa server:"..conf.aasvr.. " by [request:"..requestedapi..", scope:"..scope..", userid:"..userid..", username:"..username.."]")
      -- For simple singleshot requests, use the URI interface.
      local http = require "resty.http"
      local httpc = http.new()
      --- below line will fail, so 
      --- local svr = conf.aasrv
      local tmp = ""
      local svr  = tmp..conf.aasvr

      ngx.log(ngx.INFO, "svr:"..svr);
      local res, err = httpc:request_uri(svr,{
      -- local res, err = httpc:request_uri("http://10.245.247.180:7612/authorize",{ 
        method = "GET",
        body = "user=user&pass=password",
        headers = {
          ["Content-Type"] = "application/x-www-form-urlencoded",
          ["customer-name"] = username,
          ["authenticated-userid"] = userid,
          ["scope"] = scope,
          ["requestedapi"] = requestedapi
        }
      })

      if not res then
        ngx.log(ngx.ERR, "failed to request:"..conf.aasvr)
        return responses.send(400, "authz server error")
      end

      ngx.status = res.status
      if ngx.status == 200 then
        ngx.log(ngx.INFO, "result body:"..res.body)
        if res.body == "authorized" then
          ngx.log(ngx.INFO, "api call granted!")
        else
          ngx.log(ngx.ERR, "api call not granted")
          return responses.send(401, res.body)
        end
      else
          ngx.log(ngx.ERR, "api call error "..ngx.status.."! treated as denied")
          return responses.send(401, res.body)
      end
  else
    ngx.log(ngx.ERR, "AA server not found!")
    return responses.send(501, "AA server not implemented")
  end
end

return _M
