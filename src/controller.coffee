MAC.factory "MacPromiseController", ->
  class MacPromiseController
    constructor: ->
      @registered = {}

    register: (state, linker) ->
      @registered[state] = linker

    switchState: (state, value, element) ->
      if linker = @registered[state]
        linker value, element

    prepare: (promise, element) ->
      promise.then (result) =>
        @switchState "success", result, element
        return result

      , (reason) =>
        @switchState "error", reason, element
        return reason

      @switchState "loading", null, element
