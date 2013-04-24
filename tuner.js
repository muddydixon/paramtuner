var Strategy, Tuner, TuningWatcher, d3;

d3 = require('d3');

Strategy = require('./lib/strategy');

TuningWatcher = require('./lib/tuning_watcher');

module.exports = Tuner = (function() {

  function Tuner(opt) {
    if (opt == null) {
      opt = {};
    }
    if (!(opt.command != null) || typeof opt.command !== 'function') {
      throw new Error('command required and it must be function.');
    }
    if (!(opt.params != null) || typeof opt.params !== 'object') {
      throw new Error('params required');
    }
    this.configure(opt);
  }

  Tuner.prototype.configure = function(opt) {
    var availableStrategies, key;
    this.command = opt.command;
    if ((opt.done != null) && typeof opt.done === 'function') {
      this.done = opt.done;
    }
    if ((opt.env != null) && typeof opt.env === 'function' && typeof opt.env() === 'function') {
      this.env = opt.env();
    } else {
      this.env = function() {
        return {};
      };
    }
    if ((opt.prepare != null) && typeof opt.prepare === 'function') {
      this.prepare = opt.prepare;
    } else {
      this.prepare = function(next) {
        return next(null, {});
      };
    }
    this.trace = opt.trace || false;
    this.params = opt.params || {};
    this.maxTrialCount = opt.maxTrialCount || 10;
    this.targetCost = opt.targetCost || 0.1;
    availableStrategies = Strategy.getAvailableStrategies();
    if (availableStrategies[opt.strategy] != null) {
      this.strategy = new availableStrategies[opt.strategy](opt.params);
    } else {
      this.strategy = new availableStrategies['greedy'](opt.params);
    }
    if (!this.strategy instanceof Strategy) {
      throw Error("unavailable strategy (" + opt.strategy + ")\n now availables Strategies are " + (((function() {
        var _results;
        _results = [];
        for (key in availableStrategies) {
          _results.push(key);
        }
        return _results;
      })()).join('\n')));
    }
  };

  Tuner.prototype.start = function() {
    var beginTime, trialCount, watcher,
      _this = this;
    beginTime = new Date();
    trialCount = 0;
    watcher = new TuningWatcher(this.maxTrialCount, this.targetCost, function(err, iterationData) {
      var bestCost, bestParams, cost, iteration, _i, _len;
      if (err != null) {
        return _this.done(err);
      }
      if (!(iterationData != null)) {
        return _this.done(Error('no iteration data'));
      }
      bestCost = Infinity;
      bestParams = null;
      for (_i = 0, _len = iterationData.length; _i < _len; _i++) {
        iteration = iterationData[_i];
        iteration.cost = cost = Number(iteration.cost) || parseInt(iteration.cost);
        if (cost < bestCost) {
          bestCost = cost;
          bestParams = iteration.params;
        }
      }
      return _this.done(err, {
        best: {
          cost: bestCost,
          params: bestParams
        },
        iteration: iterationData
      }, {
        begin: beginTime,
        end: new Date()
      });
    });
    return this.prepare(function(err, topic) {
      var trial;
      if (err != null) {
        return watcher.emit('error', err);
      }
      trial = function(params) {
        var _env;
        _env = _this.env();
        _env.$topic = topic;
        _env.$trialCount = trialCount;
        return _this.command(_env, params, function(err, cost) {
          if (err != null) {
            return watcher.emit('error', err);
          }
          watcher.emit('data', params, cost);
          if (_this.isEndOfTrial(trialCount++, cost)) {
            return watcher.emit('end');
          } else {
            return trial(_this.strategy.getParamSet(cost));
          }
        });
      };
      return trial(_this.strategy.getParamSet());
    });
  };

  Tuner.prototype.isEndOfTrial = function(trialCount, cost) {
    if (trialCount > this.maxTrialCount || cost < this.targetCost) {
      return true;
    }
    return false;
  };

  Tuner.prototype.done = function(err, results, time) {
    var bestCase, bestCost, result, _i, _len;
    bestCase = null;
    bestCost = Infinity;
    for (_i = 0, _len = results.length; _i < _len; _i++) {
      result = results[_i];
      if (result.cost < bestCost) {
        bestCost = result.cost;
        bestCase = result;
      }
    }
    console.log("tuning: " + results.length + " cases, time: " + ((time.end - time.begin) / 1000) + " sec");
    console.log("\tbest score: " + bestCase.cost);
    return console.log("\ton: " + (JSON.stringify(bestCase.params)));
  };

  return Tuner;

})();
