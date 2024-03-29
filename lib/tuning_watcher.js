var EventEmitter, TuningWatcher,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

EventEmitter = require('events').EventEmitter;

module.exports = TuningWatcher = (function(_super) {

  __extends(TuningWatcher, _super);

  function TuningWatcher(limit, threshold, done) {
    var _this = this;
    this.limit = limit;
    this.threshold = threshold;
    this.done = done;
    this.data = [];
    this.cnt = 0;
    this.on('data', function(params, cost) {
      _this.data.push({
        params: params,
        cost: cost
      });
      _this.cnt++;
      if (_this.cnt === _this.limit || cost < _this.threshold) {
        return _this.emit('end', null, _this.data);
      }
    });
    this.on('error', function(err) {
      return _this.emit('end', err);
    });
    this.on('end', function(err, data) {
      _this.removeAllListeners();
      return typeof done === "function" ? done(err, data) : void 0;
    });
  }

  return TuningWatcher;

})(EventEmitter);
