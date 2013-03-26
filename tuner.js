// Generated by CoffeeScript 1.4.0
var ConfigError, Strategy, Tuner, TuningWatcher, d3;

d3 = require('d3');

Strategy = require('./lib/strategy');

TuningWatcher = require('./lib/tuningwatcher');

ConfigError = require('./lib/configerror');

module.exports = Tuner = (function() {

  function Tuner(opt) {
    if (opt == null) {
      opt = {};
    }
    if (!(opt.command != null) || typeof opt.command !== 'function') {
      throw new ConfigError('command required and it must be function.');
    }
    this.command = opt.command;
    this.done = (opt.done != null) && typeof opt.done === 'function' ? opt.done : this.done;
    this.env = (opt.env != null) && typeof opt.env === 'function' && typeof opt.env() === 'function' ? opt.env() : function() {
      return {};
    };
    this.before = (opt.before != null) && typeof opt.before === 'function' ? opt.before : function(next) {
      return next(null, {});
    };
    this.trace = opt.trace || false;
    this.params = opt.params || {};
    this.maxTrialCount = opt.maxTrialCount || 10;
    this.targetCost = opt.targetCost || 0.1;
    this.strategy = new Strategy.RandomStrategy(this.params);
    if (opt.strategy instanceof Strategy) {
      this.strategy = opt.strategy;
    } else if (typeof opt.strategy === 'string' && (Strategy[opt.strategy] != null)) {
      new Strategy[opt.strategy](this.params);
    }
  }

  Tuner.prototype.start = function() {
    var beginTime, command, done, env, isEndOfTrial, strategy, trace, trialCount, watcher,
      _this = this;
    beginTime = new Date();
    trialCount = 0;
    done = this.done;
    env = this.env;
    command = this.command;
    strategy = this.strategy;
    trace = this.trace;
    isEndOfTrial = this.isEndOfTrial;
    watcher = new TuningWatcher(this.maxTrialCount, this.targetCost, function(err, results) {
      return done(err, results, {
        begin: beginTime,
        end: new Date()
      });
    });
    return this.before(function(err, topic) {
      var trial;
      if (err != null) {
        return watcher.emit('error', err);
      }
      trial = function(params) {
        var _env;
        _env = env();
        _env.$topic = topic;
        _env.$trialCount = trialCount;
        return command(_env, params, function(err, cost) {
          if (err != null) {
            return watcher.emit('error', err);
          }
          watcher.emit('data', params, cost);
          if (_this.isEndOfTrial(trialCount++, cost)) {
            return watcher.emit('end');
          } else {
            return trial(strategy.getParamSet(cost));
          }
        });
      };
      return trial(strategy.getParamSet());
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
