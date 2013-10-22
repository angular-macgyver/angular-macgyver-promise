describe "macPromise Directive", ->
  # Initialize these values up here
  scope    = null
  $compile = null
  $q       = null

  promiseTests = (element, deferred, template) ->
    beforeEach ->
      deferred         = $q.defer()
      scope.getPromise = -> deferred.promise
      element          = $compile(template)(scope)
      scope.$apply()

    it "should start in the loading state", ->
      expect(element.text().trim()).toBe "Loading..."

    it "should output the success value", ->
      text = "Hello Whirled"
      deferred.resolve text
      scope.$apply()
      expect(element.text().trim()).toBe text

    it "should output the error value", ->
      text = "Panic now!"
      deferred.reject text
      scope.$apply()
      expect(element.text().trim()).toBe text

  beforeEach module "Mac"

  beforeEach inject ($rootScope, _$compile_, _$q_) ->
    $compile = _$compile_
    $q       = _$q_
    scope    = $rootScope.$new()

  describe "Controller", ->
    controller = null

    beforeEach inject (MacPromiseController) ->
      controller = new MacPromiseController()

    it "should register a state", ->
      callback = ->
      controller.register "default", callback
      expect(controller.registered.default).toBe callback

    it "should call the function for a registered state with the correct args", ->
      element  = angular.element "<div></div>"
      callback = jasmine.createSpy "callback"

      controller.register "default", callback
      controller.switchState "default", "bar", element

      expect(callback).toHaveBeenCalledWith "bar", element

    it "should switch states correctly with a prepared promise", ->
      actions = ["resolve", "reject"]
      states  = ["success", "error", "loading"]
      element = angular.element "<div></div>"

      for action in actions
        deferred = $q.defer()
        promise  = deferred.promise
        element  = null
        value    = null

        stateCallbacks =
          jasmine.createSpyObj 'stateCallbacks', states

        # Register each state
        for state in states
          controller.register state, stateCallbacks[state]

        # Prepare the promise
        controller.prepare promise, element

        # Preparing the promise will put us into the loading state
        expect(stateCallbacks.loading).toHaveBeenCalled()

        # Either resolve or reject the promise
        scope.$apply ->
          deferred[action] "foo"

        if action is "resolve"
          expect(stateCallbacks.success).toHaveBeenCalledWith "foo", element
        else
          expect(stateCallbacks.error).toHaveBeenCalledWith "foo", element

  describe "Default", ->
    element  = null
    deferred = null
    template = """
      <main>
        <div mac-promise="getPromise()" >
          <mac-promise-loading>Loading...</mac-promise-loading>
          <mac-promise-success>{{$result}}</mac-promise-success>
          <mac-promise-error>{{$error}}</mac-promise-error>
        </div>
      </main>
    """

    promiseTests element, deferred, template

  describe "macPromiseAs", ->
    element  = null
    deferred = null
    template = """
      <main>
        <div mac-promise="getPromise()">
          <mac-promise-loading>Loading...</mac-promise-loading>
          <mac-promise-success mac-promise-as="foo">{{foo}}</mac-promise-success>
          <mac-promise-error mac-promise-as="bar">{{bar}}</mac-promise-error>
        </div>
      </main>
    """

    promiseTests element, deferred, template

  describe "macPromiseTrigger", ->
    element  = null
    template = """
      <main>
        <button ng-click="start()"></button>
        <div mac-promise="getPromise()" mac-promise-trigger="start">
          <mac-promise-success>{{$result}}</mac-promise-success>
        </div>
      </main>
    """

    beforeEach ->
      scope.getPromise = -> $q.when "Hello Whirled"
      element          = $compile(template)(scope)
      scope.$apply()

    it "should put a function called `start` on the scope", ->
      expect(typeof scope.start).toBe "function"

    it "shouldn't have resolved the promise", ->
      expect(element.text().trim()).toBe ""

    it "should resolve the promise after `start` is called", ->
      scope.$apply -> scope.start()
      expect(element.text().trim()).toBe "Hello Whirled"

