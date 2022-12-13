local typedefs = require "kong.db.schema.typedefs"


local ORDERED_PERIODS = { "second", "minute", "hour", "day", "month", "year"}


local function validate_periods_order(config)
  for i, lower_period in ipairs(ORDERED_PERIODS) do
    local v1 = config[lower_period]
    if type(v1) == "number" then
      for j = i + 1, #ORDERED_PERIODS do
        local upper_period = ORDERED_PERIODS[j]
        local v2 = config[upper_period]
        if type(v2) == "number" and v2 < v1 then
          return nil, string.format("The limit for %s(%.1f) cannot be lower than the limit for %s(%.1f)",
                                    upper_period, v2, lower_period, v1)
        end
      end
    end
  end

  return true
end

local function validate_quotas(pair)
  local name, value = pair:match("^([^:]+):([0-9]+)$")



  if name ~= nil and value ~= nil then
    return true
  end
  return false
end

local function is_dbless()
  local _, database, role = pcall(function()
    return kong.configuration.database,
           kong.configuration.role
  end)

  return database == "off" or role == "control_plane"
end


local policy
if is_dbless() then
  policy = {
    type = "string",
    default = "local",
    len_min = 0,
    one_of = {
      "local",
      "redis",
    },
  }

else
  policy = {
    type = "string",
    default = "local",
    len_min = 0,
    one_of = {
      "local",
      "cluster",
      "redis",
    },
  }
end



local quotas = {
  type = "record",
  fields = {
    { second = {
      type = "array",
        elements = {
          type = "string",
          match = "^[^:]+:.*$",
          custom_validator = validate_quotas,
        }
      }
    },
    { minute = {
      type = "array",
        elements = {
          type = "string",
          match = "^[^:]+:.*$",
          custom_validator = validate_quotas,
        }
      }
    },
    { hour = {
      type = "array",
        elements = {
          type = "string",
          match = "^[^:]+:.*$",
          custom_validator = validate_quotas,
        }
      }
    },
    { day = {
      type = "array",
        elements = {
          type = "string",
          match = "^[^:]+:.*$",
          custom_validator = validate_quotas,
        }
      }
    },
    { month = {
      type = "array",
        elements = {
          type = "string",
          match = "^[^:]+:.*$",
          custom_validator = validate_quotas,
        }
      }
    },
    { year = {
      type = "array",
        elements = {
          type = "string",
          match = "^[^:]+:.*$",
          custom_validator = validate_quotas,
        }
      }
    },
  }
}


return {
  name = "rate-limiting-quotas",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { second = { type = "number", gt = 0 }, },
          { minute = { type = "number", gt = 0 }, },
          { hour = { type = "number", gt = 0 }, },
          { day = { type = "number", gt = 0 }, },
          { month = { type = "number", gt = 0 }, },
          { year = { type = "number", gt = 0 }, },
          { limit_by = {
              type = "string",
              default = "consumer",
              one_of = { "consumer", "credential", "ip", "service", "header", "path" },
          }, },
          { header_name = typedefs.header_name },
          { path = typedefs.path },
          { policy = policy },
          { fault_tolerant = { type = "boolean", required = true, default = true }, },
          { redis_host = typedefs.host },
          { redis_port = typedefs.port({ default = 6379 }), },
          -- only works in Kong 3.x.x
          -- { redis_password = { type = "string", len_min = 0, referenceable = true }, },
          -- { redis_username = { type = "string", referenceable = true }, },
          { redis_password = { type = "string", len_min = 0 }, },
          { redis_username = { type = "string" }, },
          --
          { redis_ssl = { type = "boolean", required = true, default = false, }, },
          { redis_ssl_verify = { type = "boolean", required = true, default = false }, },
          { redis_server_name = typedefs.sni },
          { redis_timeout = { type = "number", default = 2000, }, },
          { redis_database = { type = "integer", default = 0 }, },
          { hide_client_headers = { type = "boolean", required = true, default = false }, },
          { quotas = quotas },
        },
        custom_validator = validate_periods_order,
      },
    },
  },
  entity_checks = {
    { at_least_one_of = { "config.second", "config.minute", "config.hour", "config.day", "config.month", "config.year" } },
    { custom_entity_check = {
      field_sources = {
        "config.second", "config.minute", "config.hour", "config.day", "config.month", "config.year",
        "config.quotas.second", "config.quotas.minute", "config.quotas.hour", "config.quotas.day", "config.quotas.month", "config.quotas.year"
        },
      fn = function(entity)
          if not entity.config and not entity.config.quotas then
            return true
          end

          if entity.config.quotas.second ~= ngx.null and entity.config.second == ngx.null then
            return nil, "config.second is required"
          end
          if entity.config.quotas.minute ~= ngx.null and entity.config.minute == ngx.null then
            return nil, "config.minute is required"
          end
          if entity.config.quotas.hour ~= ngx.null and entity.config.hour == ngx.null then
            return nil, "config.hour is required"
          end
          if entity.config.quotas.day ~= ngx.null and entity.config.day == ngx.null then
            return nil, "config.day is required"
          end
          if entity.config.quotas.month ~= ngx.null and entity.config.month == ngx.null then
            return nil, "config.month is required"
          end
          if entity.config.quotas.year ~= ngx.null and entity.config.year == ngx.null then
            return nil, "config.year is required"
          end

          return true
        end
      }
    },

    { conditional = {
      if_field = "config.policy", if_match = { eq = "redis" },
      then_field = "config.redis_host", then_match = { required = true },
    } },
    { conditional = {
      if_field = "config.policy", if_match = { eq = "redis" },
      then_field = "config.redis_port", then_match = { required = true },
    } },
    { conditional = {
      if_field = "config.limit_by", if_match = { eq = "header" },
      then_field = "config.header_name", then_match = { required = true },
    } },
    { conditional = {
      if_field = "config.limit_by", if_match = { eq = "path" },
      then_field = "config.path", then_match = { required = true },
    } },
    { conditional = {
      if_field = "config.policy", if_match = { eq = "redis" },
      then_field = "config.redis_timeout", then_match = { required = true },
    } },
  },
}
