Tuner = require '../src/tuner'
expect = require('chai').expect

opt =
  params:
    alpha:
      range: [0, 10]
    beta:
      range: [0, 10]
    gamma:
      range: [0, 10]
  trace: true
  env: ()->
    ()->
      {}
  begin: (next)->
    next()
  command: (env, params, next)->
    next()
  done: ()->



describe 'Tuner', ->
  describe 'create instance', ->
    it 'create instance with command', ->
      tuner = new Tuner({command: ()->})
      expect(tuner).to.be.an.instanceof Tuner
    
    it 'create instance without command', ->
      expect(()-> new Tuner()).to.throw(Error)

    it 'has options', ->
      tuner = new Tuner opt

  describe 'start tuning', ->
    it 'occur error in command', (done)->
      tuner = new Tuner
        command: (env, params, next)->
          next(Error('command error'))
        done: (err, results, time)->
          expect(err).to.be.exist
          done()
          
      tuner.start()
      
    it 'less than 0.1', (done)->
      tuner = new Tuner
        command: (env, params, next)->
          next(null, 1 / env.$trialCount / 2)
        done: (err, results, time)->
          bestCase = null
          bestCost = Infinity
          for result in results
            if result.cost < bestCost
              bestCost = result.cost
              bestCase = result
          expect(bestCost).to.be.below(0.1)
          done()
          
      tuner.start()
      
    it 'over maxTrialCount', (done)->
      tuner = new Tuner
        command: (env, params, next)->
          next(null, 0.5)
          
        done: (err, results, time)->
          bestCase = null
          bestCost = Infinity
          for result in results
            if result.cost < bestCost
              bestCost = result.cost
              bestCase = result
          expect(bestCost).not.to.be.below 0.1
          expect(results.length).to.be.equal 10
          done()
          
      tuner.start()
      
    it 'take topic by begin', (done)->
      tuner = new Tuner
        command: (env, params, next)->
          expect(env.$topic.name).to.be.equal 'muddy'
          next(null, 0.5)

        begin: (next)->
          next null, {name: 'muddy'}
          
        done: (err, results, time)->
          bestCase = null
          bestCost = Infinity
          for result in results
            if result.cost < bestCost
              bestCost = result.cost
              bestCase = result
          expect(bestCost).not.to.be.below 0.1
          expect(results.length).to.be.equal 10
          done()
          
      tuner.start()
      
    it 'take topic error by begin', (done)->
      tuner = new Tuner
        command: (env, params, next)->
          next(null, 0.5)

        begin: (next)->
          next Error('topic error')
        done: (err, results, time)->
          expect(err).to.be.exist
          done()
          
      tuner.start()
      
    it 'take env', (done)->
      tuner = new Tuner
        command: (env, params, next)->
          expect(env.mycount).to.be.exist
          next(null, 0.5)
        env: ()->
          mycount = 0
          ()->
            {mycount: mycount++}
            
        done: (err, results, time)->
          expect(results).have.length 10
          done()
          
      tuner.start()
      
