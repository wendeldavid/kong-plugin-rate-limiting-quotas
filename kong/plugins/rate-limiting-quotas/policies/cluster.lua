local timestamp = require "kong.tools.timestamp"


local kong = kong
local concat = table.concat
local ipairs = ipairs
local floor = math.floor
local fmt = string.format
local tonumber = tonumber
local tostring = tostring


local EXPIRATION = require "kong.plugins.rate-limiting-quotas.expiration"


local find
do
  local find_pk = {}

  find = function(identifier, period, current_timestamp, service_id, route_id)
      local periods = timestamp.get_timestamps(current_timestamp)

      find_pk.identifier  = identifier
      find_pk.period      = period
      find_pk.period_date = floor(periods[period] / 1000)
      find_pk.service_id  = service_id
      find_pk.route_id    = route_id

      return kong.db.ratelimitingquotas_metrics:select(find_pk)
  end
end


return {
  postgres = {
    increment = function(connector, limits, identifier, current_timestamp, service_id, route_id, value)
      local buf = { "BEGIN" }
      local len = 1
      local periods = timestamp.get_timestamps(current_timestamp)
      for period, period_date in pairs(periods) do
        if limits[period] then
          len = len + 1
          buf[len] = fmt([[
            INSERT INTO "ratelimitingquotas_metrics" ("identifier", "period", "period_date", "service_id", "route_id", "value", "ttl")
                 VALUES (%s, %s, TO_TIMESTAMP(%s) AT TIME ZONE 'UTC', %s, %s, %s, CURRENT_TIMESTAMP AT TIME ZONE 'UTC' + INTERVAL %s)
            ON CONFLICT ("identifier", "period", "period_date", "service_id", "route_id") DO UPDATE
                    SET "value" = "ratelimitingquotas_metrics"."value" + EXCLUDED."value"
          ]],
            connector:escape_literal(identifier),
            connector:escape_literal(period),
            connector:escape_literal(tonumber(fmt("%.3f", floor(period_date / 1000)))),
            connector:escape_literal(service_id),
            connector:escape_literal(route_id),
            connector:escape_literal(value),
            connector:escape_literal(tostring(EXPIRATION[period]) .. " second"))
        end
      end

      if len > 1 then
        local sql
        if len == 2 then
          sql = buf[2]

        else
          buf[len + 1] = "COMMIT;"
          sql = concat(buf, ";\n")
        end

        local res, err = connector:query(sql)
        if not res then
          return nil, err
        end
      end

      return true
    end,
    find = find,
  },
}
