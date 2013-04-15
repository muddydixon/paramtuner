EventEmitter = require('events').EventEmitter
#
# # TuningWatcher
#
# TuningWatcher watches the tuning, keeps costs of each trial
# and fires `done` when the tuning end.
#
# * @limit: maximum number of procedure
# * @threshold: cost threshold used by comparing each trial
# * @done: function fired when trial number over limit or cost below threshold
# 
module.exports = class TuningWatcher extends EventEmitter
  constructor: (@limit, @threshold, @done)->
    @data = []
    @cnt = 0
    @on 'data', (params, cost)=>
      @data.push 
        params: params
        cost: cost
        
      @cnt++

      if @cnt is @limit or cost < @threshold
        @emit 'end', null, @data
        
    @on 'error', (err)=>
      @emit 'end', err
      
    @on 'end', (err, data)=>
      @removeAllListeners()
      done?(err, data)

    