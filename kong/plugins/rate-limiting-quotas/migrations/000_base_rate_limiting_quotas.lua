return {
    postgres = {
      up = [[
        CREATE TABLE IF NOT EXISTS "ratelimitingquotas_metrics" (
          "identifier"   TEXT                         NOT NULL,
          "period"       TEXT                         NOT NULL,
          "period_date"  TIMESTAMP WITH TIME ZONE     NOT NULL,
          "service_id"   UUID                         NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::UUID,
          "route_id"     UUID                         NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::UUID,
          "value"        INTEGER,

          PRIMARY KEY ("identifier", "period", "period_date", "service_id", "route_id")
        );
      ]],
    },
  }
