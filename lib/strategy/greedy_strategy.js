var GreedyStrategy,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = GreedyStrategy = (function(_super) {

  __extends(GreedyStrategy, _super);

  function GreedyStrategy() {
    return GreedyStrategy.__super__.constructor.apply(this, arguments);
  }

  GreedyStrategy.prototype.getParamSet = function() {
    var key, param, val, _ref;
    param = {};
    _ref = this.params;
    for (key in _ref) {
      val = _ref[key];
      param[key] = val(Math.random());
    }
    return param;
  };

  return GreedyStrategy;

})(require('../strategy'));
