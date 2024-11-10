---
--- Migration "1730997573_initial"
--- Date: 1730997573 - 11/07/24 19:39:33
---


return {
    up = function()
        box.schema.space.create("queue", nil)
        box.space.queue:format({ {
            name = "id",
            type = "string"
          }, {
            name = "time",
            type = "number"
          }, {
            name = "payload",
            type = "any"
          } })
        box.space.queue:create_index("primary", {
          parts = { { 1, "string",
              is_nullable = false
            } },
          type = "tree"
        })
        box.space.queue:create_index("time", {
          parts = { { 2, "number",
              is_nullable = false
            }, { 1, "string",
              is_nullable = false
            } },
          type = "tree"
        })
        box.space._spacer_models:replace({"queue"})
        box.schema.space.create("cache", nil)
        box.space.cache:format({ {
            name = "id",
            type = "string"
          }, {
            name = "expires",
            type = "number"
          }, {
            name = "payload",
            type = "any"
          } })
        box.space.cache:create_index("primary", {
          parts = { { 1, "string",
              is_nullable = false
            } },
          type = "tree"
        })
        box.space.cache:create_index("expires", {
          parts = { { 2, "number",
              is_nullable = false
            } },
          type = "tree",
          unique = false
        })
        box.space._spacer_models:replace({"cache"})
    end,

    down = function()
        box.space.queue:drop()
        box.space._spacer_models:delete({"queue"})
        box.space.cache:drop()
        box.space._spacer_models:delete({"cache"})
    end,
}
