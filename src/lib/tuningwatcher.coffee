EventEmitter = require('events').EventEmitter
############################################################
#
# TuningWatcher
# 
module.exports = class TuningWatcher extends EventEmitter
  constructor: (@limit, @target, @callback)->
    @data = []
    @cnt = 0
    @on 'data', (params, cost)=>
      @data.push 
        params: params
        cost: cost
        
      @cnt++

      if @cnt is @limit or cost < @target
        @emit 'end', null, @data
        
    @on 'error', (err)=>
      @emit 'end', err
      
    @on 'end', (err, data)=>
      @removeAllListeners()
      callback?(err, data)

    