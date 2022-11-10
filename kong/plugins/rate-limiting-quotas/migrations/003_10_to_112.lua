return {
    postgres = {
      up = [[
        CREATE INDEX IF NOT EXISTS ratelimitingquotas_metrics_idx ON ratelimitingquotas_metrics (service_id, route_id, period_date, period);
      ]],
    },

    cassandra = {
      up = [[
      ]],
    },
  }