var GeneralizedLinearStrategy, d3,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

d3 = require('d3');

module.exports = GeneralizedLinearStrategy = (function(_super) {

  __extends(GeneralizedLinearStrategy, _super);

  function GeneralizedLinearStrategy(params, grid) {
    var i, idx, key, param, prod, prods, val, _i, _j, _k, _len, _params, _ref, _ref1, _ref2, _ref3, _results;
    grid = grid || 3;
    GeneralizedLinearStrategy.__super__.constructor.call(this, params);
    this.initialiSet = [];
    this.results = [];
    _params = {};
    _ref = this.params;
    for (key in _ref) {
      val = _ref[key];
      _params[key] = (function() {
        _results = [];
        for (var _i = 0, _ref1 = grid - 1; 0 <= _ref1 ? _i <= _ref1 : _i >= _ref1; 0 <= _ref1 ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this).map(function(d) {
        return val(d / (grid - 1));
      });
    }
    prods = {};
    prod = 1;
    _ref2 = d3.entries(_params);
    for (idx = _j = 0, _len = _ref2.length; _j < _len; idx = ++_j) {
      param = _ref2[idx];
      prods[param.key] = prod;
      prod *= param.value.length;
    }
    for (i = _k = 0, _ref3 = prod - 1; 0 <= _ref3 ? _k <= _ref3 : _k >= _ref3; i = 0 <= _ref3 ? ++_k : --_k) {
      this.initialiSet[i] = {};
      for (key in _params) {
        val = _params[key];
        this.initialiSet[i][key] = val[(0 | i / prods[key]) % val.length];
      }
    }
    this.prod = prod;
  }

  GeneralizedLinearStrategy.prototype.getParamSet = function(cost) {
    var params;
    GeneralizedLinearStrategy.__super__.getParamSet.call(this);
    if (cost != null) {
      this.results.push(cost);
    }
    if (this.t >= this.prod) {
      if (this.t === this.prod) {
        this.generateGLModel();
      }
      return {};
    } else {
      return params = this.initialiSet[this.t];
    }
  };

  GeneralizedLinearStrategy.prototype.generateGLModel = function() {
    var cost, key, theta;
    console.log('when generalized');
    theta = {};
    for (key in this.params) {
      theta[key] = Math.random() - 0.5;
    }
    return cost = this.calculateCost(theta);
  };

  GeneralizedLinearStrategy.prototype.calculateCost = function(theta) {
    var costs, idx, key, set, val, _i, _len, _ref;
    costs = [];
    _ref = this.initialiSet;
    for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
      set = _ref[idx];
      costs.push(this.results[idx] - d3.sum((function() {
        var _results;
        _results = [];
        for (key in set) {
          val = set[key];
          _results.push(val * theta[key]);
        }
        return _results;
      })()));
    }
    return d3.sum(costs);
  };

  return GeneralizedLinearStrategy;

})(require('../strategy'));
