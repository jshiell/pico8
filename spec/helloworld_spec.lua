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

    describe("attack pattern alpha", function()
        it("should mark actors for deletion when they leave the bounds of the screen + margin", function()
            local actor_to_be_deleted = {
                ax = -40,
                ay = 12,
                vx = -2,
                vy = 0
            }

            attack_pattern_alpha(actor_to_be_deleted)

            assert.are.equals(true, actor_to_be_deleted.delete_me)
        end)
    end)

end)
