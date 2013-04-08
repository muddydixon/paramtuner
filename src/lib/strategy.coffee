d3 = require 'd3'
############################################################
#
# Strategy interface
#
class Strategy
  constructor: (params)->
    @t = -1
    @params = {}
    for name, dat of params
      if dat.range?
        @params[name] = d3.scale.linear().range(dat.range)
      else if dat.enum?
        @params[name] = ()-> dat.enum[0|Math.random() * dat.enum.length]
      else
        do (dat)=>
          @params[name] = ()-> dat
    
  getParamSet: ()->
    @t++
  showParams: (params)->
    ("#{key}: #{val}" for key, val of params).join ', '
    
############################################################
#
# RandomStrategy
#
class Strategy.RandomStrategy extends Strategy
  constructor: (params)->
    super(params)
    
  getParamSet: ->
    super()
    param = {}
    for key, val of @params
      param[key] = val(Math.random())
    param

############################################################
#
# GeneralizedLinearStrategy
#
class Strategy.GeneralizedLinearStrategy extends Strategy
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


############################################################
#
# module.exports
#
module.exports = Strategy

############################################################
#
# unit test
#
unless module.parent?
  params =
    alpha:
      range: [1, 10]
    beta:
      range: [0, 1]
    gamma:
      range: [10, 20]
  strategy = new Strategy.GeneralizedLinearStrategy(params, 3)
  for i in [0..30 - 1]
    strategy.getParamSet(i)
