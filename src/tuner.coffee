d3 = require 'd3'
Strategy = require './lib/strategy'
TuningWatcher = require './lib/tuningwatcher'
ConfigError = require './lib/configerror'

module.exports = class Tuner
  constructor: (opt= {})->
    # check setting
    if not opt.command? or typeof opt.command isnt 'function'
      throw new ConfigError('command required and it must be function.')

    # methods
    @command = opt.command
    @done = if opt.done? and typeof opt.done is 'function' then opt.done else @done
    @env = if opt.env? and typeof opt.env is 'function' and typeof opt.env() is 'function' then opt.env() else ()-> {}
    @before = if opt.before? and typeof opt.before is 'function' then opt.before else (next)-> next(null, {})

    # values
    @trace = opt.trace or false
    @params = opt.params or {}
    @maxTrialCount = opt.maxTrialCount or 10
    @targetCost = opt.targetCost or 0.1

    # strategy
    @strategy = new Strategy.RandomStrategy(@params)
    if opt.strategy instanceof Strategy
      @strategy = opt.strategy
    else if typeof opt.strategy is 'string' and Strategy[opt.strategy]?
      new Strategy[opt.strategy](@params)

  start: ()->
    beginTime = new Date()
    trialCount = 0
    
    # localise
    done = @done
    env = @env
    command = @command
    strategy = @strategy
    trace = @trace
    isEndOfTrial = @isEndOfTrial


    # watcher start
    watcher = new TuningWatcher(@maxTrialCount, @targetCost, (err, results)->
      done(err, results, {begin: beginTime, end: new Date()})
    )
    
    # before
    @before (err, topic)=>

      if err?
        return watcher.emit 'error', err

      # trial command
      trial = (params)=>
        _env = env()
        _env.$topic = topic
        _env.$trialCount = trialCount

        command _env, params, (err, cost)=>
          if err?
            return watcher.emit 'error', err
          watcher.emit 'data', params, cost
          if @isEndOfTrial(trialCount++, cost)
            watcher.emit 'end'
          else
            trial(strategy.getParamSet(cost))
        
      trial(strategy.getParamSet())

  isEndOfTrial: (trialCount, cost)->
    if trialCount > @maxTrialCount or cost < @targetCost
      return true
    false

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
