local helpers = require "spec.helpers"


local PLUGIN_NAME = "rate-limiting-quotas"


for _, strategy in helpers.each_strategy() do
  if strategy ~= "cassandra" then
    describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
      local client

      lazy_setup(function()

        local bp = helpers.get_db_utils(strategy == "off" and "postgres" or strategy, {
          "routes",
          "services",
          "plugins",
          "consumers",
          "keyauth_credentials",
          "acls",
        }, { PLUGIN_NAME })

        -- Inject a test route. No need to create a service, there is a default
        -- service which will echo the request.
        local route1 = bp.routes:insert({
          paths = { "/request_test" }
        })

        -- add the plugin to test to the route we created
        bp.plugins:insert {
          name = "key-auth",
          route = { id = route1.id },
          config = {},
        }

        local consumer = bp.consumers:insert {
          username = "consumer_name",
        }

        bp.keyauth_credentials:insert {
          key = "key-test",
          consumer = { id = consumer.id },
        }

        bp.acls:insert {
          group = "silver",
          consumer = { id = consumer.id },
        }

        bp.plugins:insert {
          name = PLUGIN_NAME,
          route = { id = route1.id },
          config = {
            second = 2,
            minute = 10,
            policy = "cluster",
            quotas = {
              minute = { "silver:60" }
            }
          },
        }

        -- start kong
        assert(helpers.start_kong({
          -- set the strategy
          database   = strategy,
          -- use the custom test template to create a local mock server
          nginx_conf = "spec/fixtures/custom_nginx.template",
          -- make sure our plugin gets loaded
          plugins = "bundled," .. PLUGIN_NAME,
          -- write & load declarative config, only if 'strategy=off'
          declarative_config = strategy == "off" and helpers.make_yaml_file() or nil,
        }))
      end)

      lazy_teardown(function()
        helpers.stop_kong(nil, true)
      end)

      before_each(function()
        client = helpers.proxy_client()
      end)

      after_each(function()
        if client then client:close() end
      end)

      describe("request", function()
        it("made one request", function()
          local r = client:get("/request_test", {
            headers = {
              apikey = "key-test"
            }
          })
          -- validate that the request succeeded, response status 200
          assert.response(r).has.status(200)

          local consumer_header = assert.request(r).has.header("x-consumer-username")
          assert.equal("consumer_name", consumer_header)

          -- now check the request (as echoed by mockbin) to have the header
          local rate_limit_header = assert.response(r).has.header("RateLimit-Limit-Quotas")
          -- validate the value of that header
          -- assert.equal("10", rate_limit_header)

          local rate_limit_second_period_header = assert.response(r).has.header("X-RateLimit-Limit-Quotas-Second")
          assert.equal("2", rate_limit_second_period_header)

          local rate_limit_minute_period_header = assert.response(r).has.header("X-RateLimit-Limit-Quotas-Minute")
          assert.equal("60", rate_limit_minute_period_header)
        end)
      end)


    end)
  end --cassandra if gambeta
end