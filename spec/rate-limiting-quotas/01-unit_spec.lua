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


  it("without values", function()
    local ok, err = validate({
        quotas = {}
      })
    assert.is_nil(ok)
    assert.is_truthy(err)
  end)

  it("tests with 1 quota config", function()
    local ok, err = validate({
        quotas = {
          second = { "silver:10" , "gold:100" },
        }
      })
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  it("tests with multiples quota config", function()
    local ok, err = validate({
        quotas = {
          second = { "silver:10" , "gold:100" },
          hour = { "silver:60" },
        }
      })
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

end)
