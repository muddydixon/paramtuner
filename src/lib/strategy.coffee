d3 = require 'd3'
fs = require 'fs'
path = require 'path'

#
# # Strategy interface
#
module.exports = class Strategy
  #
  # ## The constructor
  # 
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
    
  #
  # ## showParams
  #
  # * return<string>: prettyfied parameter set
  showParams: (params)->
    ("#{key}: #{val}" for key, val of params).join ', '

  #
  # ## @getAvailableStrategies
  # 
  # * dirs: strategie directories. default strategy dir is "./strategy
  # * return: map<strategyname, strategy>
  #
  @getAvailableStrategies: (dirs= [])->
    dirs.unshift path.join(__dirname, 'strategy')
    availableStrategies = {}
    dirs.map (dir)->
      strategies = fs.readdirSync(dir).filter (file)-> file.match(/_strategy\./)
      strategies.forEach (strategy)->
        availableStrategies[strategy.replace(/_strategy\.\w+$/, '')] =
          require(path.join(dir, strategy))
    availableStrategies
    
module.exports = Strategy
