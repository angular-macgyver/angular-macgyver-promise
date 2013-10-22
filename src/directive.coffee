###
@chalk overview
@name macPromise

@description
Allows templates to handle expressions returning promises. Each state of the
promise is represented by a different `mac-promise-x` child directive, and works
much like `ng-switch`. By default, the promise expression is immediately envoked, 
and any asynchonous events will begin. The evaluation can be postponed by using 
`mac-promise-trigger`, which will post a method onto the current scope, when called
will then evaluate the promise expression.

@param {Expr}   mac-promise         An expression that will return a promise
@param {String} mac-promise-trigger Optional. Postpones evaluation of the promise
                                    until the named method is called. The method
                                    is posted onto the scope by the directive.

###

MAC.directive "macPromise", [
  "MacPromiseController"
  "$parse"
  (
    MacPromiseController
    $parse
  ) ->
    controller: ["$scope", "$attrs", "$element", MacPromiseController]

    compile: ($element, $attrs, linker) ->
      (scope, element, attrs, controller) ->
        deregisterWatch = null

        watchHandler = (promise) ->
          return unless promise and typeof promise.then is "function"
          deregisterWatch()
          controller.prepare promise, element

        start = ->
          deregisterWatch = scope.$watch attrs.macPromise, watchHandler

        if attrs.macPromiseTrigger
          $parse(attrs.macPromiseTrigger).assign scope, start
        else
          start()
]

###
@chalk overview
@name macPromise(Success|Error|Loading)

@description
The three states the promise can be in. These must be children of an element 
with `macPromise`. The result of the promise is posted as a local variable in the
new scope created for this element when `macPromise` switches to it. By default 
these variables are `$result` for `mac-promise-success` and `$error` for 
`mac-promise-error`. These names can be changed by using the `mac-promise-as` attribute.

@param {None}   mac-promise-(success|error|loading) Initializes the directive
@param {String} mac-promise-as                      The name you want the local 
                                                    scope variable of the result
                                                    or error to be.
###

for state in ["Success", "Error", "Loading"]
  do (state) ->
    MAC.directive "macPromise#{state}", ->
      priority:   1000
      restrict:   "EA"
      transclude: true
      require:    "^macPromise"

      compile: ($element, $attrs, linker) ->
        (scope, element, attrs, controller) ->
          controller.register state.toLowerCase(), (value, element) ->
            currentStateScope = element.scope().$new()
            elementNode       = element[0]

            if value
              resultKey = attrs.macPromiseAs or
                if state is "Error"
                  "$error"
                else
                  "$result"

              currentStateScope[resultKey] = value

            linker currentStateScope, (clone) =>
              while elementNode.firstChild
                elementNode.removeChild elementNode.firstChild

              elementNode.appendChild clone[0]
