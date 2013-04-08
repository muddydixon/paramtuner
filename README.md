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

# Examples

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
    new Server(results.best.params).listen(80);
  }
});
tuner.start();
```

# Author

Muddy Dixon muddydixon@gmail.com

# License

Copyright 2013- Muddy Dixon (muddydixon)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
