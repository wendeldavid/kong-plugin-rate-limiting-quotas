local PLUGIN_NAME = "rate-limiting-quotas"

local inspect = require "inspect"


-- helper function to validate data against a schema
local validate do
  local validate_entity = require("spec.helpers").validate_plugin_config_schema
  local plugin_schema = require("kong.plugins."..PLUGIN_NAME..".schema")

  function validate(data)
    return validate_entity(data, plugin_schema)
  end
end


describe(PLUGIN_NAME .. ": (schema)", function()


  it("without values", function()
    local ok, err = validate({})
    assert.is_nil(ok)
    assert.is_table(err)
    assert.equals("at least one of these fields must be non-empty: 'config.second', 'config.minute', 'config.hour', 'config.day', 'config.month', 'config.year'", err["@entity"][1])
  end)

  it("tests with only quota config", function()
    local ok, err = validate({
        quotas = {
          second = { "silver:10" , "gold:100" },
        }
      })
    assert.is_nil(ok)
    assert.is_table(err)
    assert.equals("at least one of these fields must be non-empty: 'config.second', 'config.minute', 'config.hour', 'config.day', 'config.month', 'config.year'", err["@entity"][1])
  end)

  it("tests with conflict defaul/quota config", function()
    local ok, err = validate({
      minute = 15,
      quotas = {
        second = { "silver:10" },
      }
    })

    assert.is_nil(ok)
    assert.is_table(err)
    assert.equals("config.second is required", err["@entity"][1])
  end)

  it("test with only defaul limits", function()
    local ok, err = validate({
      second = 10
    })
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  it("tests with invalid quota pattern config", function()
    local ok, err = validate({
      second = 10,
      quotas = {
        second = { "silver" }
      }
    })
    assert.is_nil(ok)
    assert.is_table(err)
  end)

  it("tests with multiples quota config", function()
    local ok, err = validate({
      second = 10,
      hour = 60,
      quotas = {
        second = { "bronze,silver:10" , "gold:100" },
        hour = { "bronze,silver:60" },
      }
    })

    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

end)
