d3 = require 'd3'
#
# GeneralizedLinearStrategy
#
# This is Generalized Linear Strategy.
#
# At first it create a list of sample points,
# it generates model from results and exploration.
#
# And then it explores to the point to local minimal value.
#
module.exports = class GeneralizedLinearStrategy extends require('../strategy')
  constructor: (params, grid)->
    grid = grid or 3
    super(params)

    @initialiSet = []
    @results = []

    _params = {}
    for key, val of @params
      _params[key] = [0..grid - 1].map (d)-> val d / (grid - 1)

    prods = {}
    prod = 1
    for param, idx in d3.entries(_params)
      prods[param.key] = prod
      prod *= param.value.length

    for i in [0..prod - 1]
      @initialiSet[i] = {}
      for key, val of _params
        @initialiSet[i][key] = val[(0|i / prods[key]) % val.length]
    @prod = prod

  getParamSet: (cost)->
    super()
    if cost?
      @results.push cost
      
    if @t >= @prod
      if @t is @prod
        @generateGLModel()
      {}
    else
      params = @initialiSet[@t]
      
  generateGLModel: ()->
    console.log 'when generalized'
    
    # parameter initialize
    theta = {}
    for key of @params
      theta[key] = Math.random() - 0.5

    # calculate cost
    cost = @calculateCost(theta)

    # TODO: ここから最尤推定を行うロジック

  calculateCost: (theta)->
    costs = []
    for set, idx in @initialiSet
      costs.push @results[idx] - d3.sum (val * theta[key] for key, val of set)
    d3.sum costs


