local PLUGIN_NAME = "rate-limiting-quotas"


-- helper function to validate data against a schema
local validate do
  local validate_entity = require("spec.helpers").validate_plugin_config_schema
  local plugin_schema = require("kong.plugins."..PLUGIN_NAME..".schema")

  function validate(data)
    return validate_entity(data, plugin_schema)
  end
end


describe(PLUGIN_NAME .. ": (schema)", function()


  it("default values only", function()
    local ok, err = validate({
        second = 10,
        minute = 10,
        hour = 10,
        day = 10,
        month = 10,
        year = 10,
        quotas = {}
      })
    assert.is_nil(err)
    assert.is_truthy(ok)
    print(err)
  end)

  it("tests with 1 quota config", function()
    local ok, err = validate({
        second = 10,
        minute = 10,
        hour = 10,
        day = 10,
        month = 10,
        year = 10,
        quotas = {
          second = { "silver:10" , "gold:100" },
        }
      })
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  it("tests with multiples quota config", function()
    local ok, err = validate({
        second = 10,
        minute = 10,
        hour = 10,
        day = 10,
        month = 10,
        year = 10,
        quotas = {
          second = { "silver:10" , "gold:100" },
          hour = { "silver:60" },
        }
      })
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  -- it("does not accept identical request_header and response_header", function()
  --   local ok, err = validate({
  --       request_header = "they-are-the-same",
  --       response_header = "they-are-the-same",
  --     })

  --   assert.is_same({
  --     ["config"] = {
  --       ["@entity"] = {
  --         [1] = "values of these fields must be distinct: 'request_header', 'response_header'"
  --       }
  --     }
  --   }, err)
  --   assert.is_falsy(ok)
  -- end)


end)
