# param tuner

Easily parameter tuning in your code!

# Usage

```shell
npm install paramtuner
```

and 

```javascript
var Tuner = require('paramtuner');
var tuner = new Tuner({command: function(env, params, next){
  next(null, 0.5);
}});
tuner.start();
```

# Example

If you want to start server with best maxConnection number:

```javascript

var Server = require('server');

var Tuner = require('paramtuner');
var tuner = new Tuner({
  params: {
    maxConnection: { range: [1, 100] }
  },
  command: function(env, params, next){
    var server = new Server({maxConnection: params.maxConnection}).listen(80);
    // pseudo code
    var timePerReq = benchmark(server, {connection: 100, request: 10000});
    next(null, timePerReq);
  },
  done: function(err, results, time){
    var bestCost = Infinity;
    var bestParams = null;
    for(var i = 0; i < results.length; i++){
      if(bestCost > results.cost){
        bestCost = results.cost;
        bestParams = results.params;
      }
    }
    new Server(bestParams).listen(80);
  }
});
tuner.start();
```


