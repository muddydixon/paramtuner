var Strategy, d3, fs, path;

d3 = require('d3');

fs = require('fs');

path = require('path');

module.exports = Strategy = (function() {

  function Strategy(params) {
    var dat, name,
      _this = this;
    this.t = -1;
    this.params = {};
    for (name in params) {
      dat = params[name];
      if (dat.range != null) {
        this.params[name] = d3.scale.linear().range(dat.range);
      } else if (dat["enum"] != null) {
        this.params[name] = function() {
          return dat["enum"][0 | Math.random() * dat["enum"].length];
        };
      } else {
        (function(dat) {
          return _this.params[name] = function() {
            return dat;
          };
        })(dat);
      }
    }
  }

  Strategy.prototype.showParams = function(params) {
    var key, val;
    return ((function() {
      var _results;
      _results = [];
      for (key in params) {
        val = params[key];
        _results.push("" + key + ": " + val);
      }
      return _results;
    })()).join(', ');
  };

  Strategy.getAvailableStrategies = function(dirs) {
    var availableStrategies;
    if (dirs == null) {
      dirs = [];
    }
    dirs.unshift(path.join(__dirname, 'strategy'));
    availableStrategies = {};
    dirs.map(function(dir) {
      var strategies;
      strategies = fs.readdirSync(dir).filter(function(file) {
        return file.match(/_strategy\./);
      });
      return strategies.forEach(function(strategy) {
        return availableStrategies[strategy.replace(/_strategy\.\w+$/, '')] = require(path.join(dir, strategy));
      });
    });
    return availableStrategies;
  };

  return Strategy;

})();

module.exports = Strategy;
