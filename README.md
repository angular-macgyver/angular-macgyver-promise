# MacGyver Promise

A directive for handling promises directly in Angular templates.

    <!--
      A simple example using Backbone
    -->
    <div mac-promise="collection.fetch()">
      <!-- While the request is happening we are in the loading state -->
      <mac-promise-loading>
        <mac-cspinner></mac-cspinner>
      </mac-promise-loading>
      <!-- Successful requests are transitioned into the success state -->
      <mac-promise-success>
        <ul>
          <li ng-repeat="model in collection.models">
            {{model.get("name")}}
          </li>
        </ul>
      </mac-promise-success>
      <!-- Unsuccessful requests transition to the error state -->
      <mac-promise-error>
        Something has gone wrong!
      </mac-promise-error>
    </div>


## Additional Properties

### macPromiseTrigger

    <div mac-promise="collection.fetch()" mac-promise-trigger="fetchCollection">
      <!-- 
        States go here, like in the above example, but the expression passed to 
        `mac-promise` isn't evaluated until `fetchCollection` is called.
      -->
    </div>
    <button ng-click="fetchCollecion()">Fetch the collection</button>

### macPromiseAs

**JS**
  
    $scope.fetchData = function(){
      return $q.when({name: "MacGyver"});
    }
    

**Template**

    <div mac-promise="fetchData()">
      <!-- 
        Both `mac-promise-success` and `mac-promise-error` get the result of the
        promise added to their scope, respectively as `$result` and `$error`. Those
        variable names can be overriden using `mac-promise-as` if desired.
      -->
      <mac-promise-success mac-promise-as="data">
        {{data.name}}
      </mac-promise-success>

      <mac-promise-error>
        The server replied with {{$error.data.message}}
      </mac-promise-error>
    </div>
