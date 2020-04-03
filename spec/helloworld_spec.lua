describe("helloworld", function()

    local p8_test = require "p8_test"
    
    p8_test.import_globals("helloworld")

    teardown(function()
        p8_test.cleanup()
    end)

    it("should create an explosion", function()
        local test_actor = {
            x = 10,
            y = 12
        }

        local result = create_explosion(test_actor, "an_initial_sprite_ref")

        assert.are.same({
            x = 10,
            y = 12,
            sprite = "an_initial_sprite_ref"
        }, result)
    end)

end)
