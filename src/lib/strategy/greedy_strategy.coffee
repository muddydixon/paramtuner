#
# RandomStrategy
#
# This is greedy strategy.
#
# It explores parameter space randamly.
#
module.exports = class GreedyStrategy extends require('../strategy')
  getParamSet: ()->
    param = {}
    for key, val of @params
      param[key] = val(Math.random())
    param

