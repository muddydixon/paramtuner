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
  prepare: (next)->
    next()
  command: (env, params, next)->
    next()
  done: ()->



describe 'Tuner', ->
  describe 'create instance', ->
    it 'create instance with command', ->
      tuner = new Tuner({command:(()->), params: opt.params})
      expect(tuner).to.be.an.instanceof Tuner
    
    it 'create instance without params', ->
      expect(()-> new Tuner({params: opt.params})).to.throw(Error)

    it 'create instance without command', ->
      expect(()-> new Tuner({command:(()->)})).to.throw(Error)

    it 'has options', ->
      tuner = new Tuner opt

  describe 'parameters', ->
    it 'options constant params ', (done)->
      tuner = new Tuner
        command: (env, params, next)->
          next(null, 0.5)
        params:
          alpha: 0.1
          beta:
            range: [0, 1]

      done()

    it 'options enum ', (done)->
      tuner = new Tuner
        command: (env, params, next)->
          next(null, 0.5)
        params:
          alpha: 0.1
          beta:
            enum: [0, 1, 2, 3]
            
      done()
        
      
  describe 'start tuning', ->
    it 'occur error in command', (done)->
      tuner = new Tuner
        command: (env, params, next)->
          next(Error('command error'))
        params: opt.params
        done: (err, results, time)->
          expect(err).to.be.exist
          done()
          
      tuner.start()
      
    it 'less than 0.1', (done)->
      tuner = new Tuner
        command: (env, params, next)->
          next(null, 1 / env.$trialCount / 2)
        params: opt.params
        done: (err, results, time)->
          expect(results).to.be.exist
          expect(results.best).to.be.exist
          expect(results.best.cost).to.be.below(0.1)
          expect(results.best.params).to.be.expect
          done()
          
      tuner.start()
      
    it 'over maxTrialCount', (done)->
      tuner = new Tuner
        command: (env, params, next)->
          next(null, 0.5)
        params: opt.params
        done: (err, results, time)->
          expect(results.best.cost).not.to.be.below 0.1
          expect(results.iteration.length).to.be.equal 10
          done()
          
      tuner.start()
      
    it 'take topic by before', (done)->
      tuner = new Tuner
        command: (env, params, next)->
          expect(env.$topic.name).to.be.equal 'muddy'
          next(null, 0.5)
        params: opt.params
        prepare: (next)->
          next null, {name: 'muddy'}
          
        done: (err, results, time)->
          expect(results.best.cost).not.to.be.below 0.1
          expect(results.iteration.length).to.be.equal 10
          done()
          
      tuner.start()
      
    it 'take topic error by before', (done)->
      tuner = new Tuner
        command: (env, params, next)->
          next(null, 0.5)

        params: opt.params
        prepare: (next)->
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
        params: opt.params
        env: ()->
          mycount = 0
          ()->
            {mycount: mycount++}
            
        done: (err, results, time)->
          expect(results.iteration).have.length 10
          done()
          
      tuner.start()


