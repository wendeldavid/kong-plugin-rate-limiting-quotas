return {
    postgres = {
      up = [[
        DO $$
        BEGIN
          ALTER TABLE IF EXISTS ONLY "ratelimitingquotas_metrics" ADD "ttl" TIMESTAMP WITH TIME ZONE;
        EXCEPTION WHEN DUPLICATE_COLUMN THEN
          -- Do nothing, accept existing state
        END$$;
        DO $$
        BEGIN
          CREATE INDEX IF NOT EXISTS "ratelimitingquotas_metrics_ttl_idx" ON "ratelimitingquotas_metrics" ("ttl");
        EXCEPTION WHEN UNDEFINED_TABLE THEN
          -- Do nothing, accept existing state
        END$$;
      ]],
    },

    cassandra = {
      up = [[
      ]],
    },
  }
