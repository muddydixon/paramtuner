Strategy = require '../src/lib/strategy'
GreedyStrategy = require '../src/lib/strategy/greedy_strategy'

expect = require('chai').expect

describe 'Strategy', ->
  describe 'static method', ->
    it 'getAvailableStrategies', ->
      for name, strategy of Strategy.getAvailableStrategies()
        expect(['generalized_linear', 'greedy'].indexOf(name)).to.be.above -1
        expect(new strategy()).to.be.an.instanceof Strategy

    
describe 'GreedyStrategy', ->
  describe 'instance', ->
    it 'generate insntance', ->
      strategy = new GreedyStrategy()
      expect(strategy).to.be.an.instanceof Strategy
      expect(strategy).to.have.property 'getParamSet'
      
    it 'params with constant', ->
      strategy = new GreedyStrategy({alpha: 0.1})
      expect(strategy.getParamSet()).to.be.deep.equal {alpha: 0.1}
      
    it 'params with range', ->
      strategy = new GreedyStrategy({alpha: {range: [0, 1]}})
      [0..100].forEach ->
        alpha = strategy.getParamSet().alpha
        expect(alpha).to.be.below 1
        expect(alpha).to.be.above 0
      
    it 'params with enum', ->
      strategy = new GreedyStrategy({alpha: {enum: [0, 1, 2, 3]}})
      [0..100].forEach ->
        alpha = strategy.getParamSet().alpha
        expect([0,1,2,3].indexOf(alpha)).to.be.above -1
        expect(alpha).to.be.equal parseInt(alpha)
