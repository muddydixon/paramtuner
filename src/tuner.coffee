d3 = require 'd3'
Strategy = require './lib/strategy'
TuningWatcher = require './lib/tuning_watcher'

#
# # Tuner
# 
module.exports = class Tuner
  #
  # ## The constructor
  #
  # * opt: configuration
  # * opt.command:function: command executed in each trial.
  # This function takes as arguments, env, params, next. next must be executed on the end of trial with the cost of this trial. 
  #
  # ```
  # command = function(env, params, next){
  #   // do procedures
  #   next(err, cost)
  # }
  # ```
  # 
  # * opt.params:object:
  #
  # ```
  # params = {
  #   alpha: {
  #     range: [0, 1]
  #   },
  #   beta: {
  #     enum: ["foo", "bar", "bra"]
  #   },
  # }
  # ```
  # 
  # * opt.done:function:
  # * opt.prepare:function:
  # * opt.env:function: you can specify environment of all of / each trials. For example port, user, password. And you can use closure
  # 
  # ```
  # env = function(){
  #   var port = 2222;
  #   return function(){
  #     return {
  #       port: port++
  #     };
  #   }
  # }
  # ```
  # 
  # * opt.strategy:Strategy:
  # * opt.trace:boolean:
  # * opt.targetCost:number:
  # * opt.maxTrialCount:number: 
  # 
  constructor: (opt= {})->
    if not opt.command? or typeof opt.command isnt 'function'
      throw new Error('command required and it must be function.')

    if not opt.params? or typeof opt.params isnt 'object'
      throw new Error('params required')

    @configure(opt)

  #
  # ## Parse configuration
  # 
  configure: (opt)->
    @command = opt.command
    if opt.done? and typeof opt.done is 'function'
      @done = opt.done
      
    if opt.env? and typeof opt.env is 'function' and typeof opt.env() is 'function'
      @env = opt.env()
    else
      @env = ()-> {}
      
    if opt.prepare? and typeof opt.prepare is 'function'
      @prepare = opt.prepare
    else
      @prepare = (next)-> next(null, {})

    @trace = opt.trace or false
    @params = opt.params or {}
    @maxTrialCount = opt.maxTrialCount or 10
    @targetCost = opt.targetCost or 0.1

    availableStrategies = Strategy.getAvailableStrategies()
    if availableStrategies[opt.strategy]?
      @strategy = new availableStrategies[opt.strategy](opt.params)
    else
      @strategy = new availableStrategies['greedy'](opt.params)

    if not @strategy instanceof Strategy
      throw Error("unavailable strategy (#{opt.strategy})\n now availables Strategies are #{(key for key of availableStrategies).join('\n')}")

  #
  # ## Start tuning
  # 
  start: ()->
    beginTime = new Date()
    trialCount = 0
    
    watcher = new TuningWatcher(@maxTrialCount, @targetCost, (err, iterationData)=>
      if err?
        return @done(err)
      if not iterationData?
        return @done Error('no iteration data')
      
      bestCost = Infinity
      bestParams = null

      for iteration in iterationData
        iteration.cost = cost = Number(iteration.cost) or parseInt iteration.cost
        if cost < bestCost
          bestCost = cost
          bestParams = iteration.params
      
      @done(err
        {best: {cost: bestCost, params: bestParams}, iteration: iterationData}
        {begin: beginTime, end: new Date()})
    )
    
    @prepare (err, topic)=>
      if err?
        return watcher.emit 'error', err

      trial = (params)=>
        _env = @env()
        _env.$topic = topic
        _env.$trialCount = trialCount

        @command _env, params, (err, cost)=>
          if err?
            return watcher.emit 'error', err
          watcher.emit 'data', params, cost
          if @isEndOfTrial(trialCount++, cost)
            watcher.emit 'end'
          else
            trial(@strategy.getParamSet(cost))
        
      trial(@strategy.getParamSet())

  #
  # ## check end of trial
  #
  # There are two cases on the condition of finishing tuning.
  # The one is the trial count and max trial count.
  # The other is the cost below the target cost.
  # 
  isEndOfTrial: (trialCount, cost)->
    if trialCount > @maxTrialCount or cost < @targetCost
      return true
    false

  #
  # ## default done function
  # 
  done: (err, results, time)->
    bestCase = null
    bestCost = Infinity
    for result in results
      if result.cost < bestCost
        bestCost = result.cost
        bestCase = result
    
    console.log "tuning: #{results.length} cases, time: #{(time.end - time.begin) / 1000} sec"
    console.log "\tbest score: #{bestCase.cost}"
    console.log "\ton: #{JSON.stringify(bestCase.params)}"
