require 'spec_helper'
require 'screamin/entities/policy'

RSpec.describe Screamin::Policy do
  let(:policy) {described_class.new}

  it 'bumps the revision' do
    expect(described_class.new.version).to eq(1)
  end

  it 'does not bumps the revision' do
    expect(described_class.new(false).version).to eq(0)
  end

  it 'toggles active' do
    expect(policy.active).to eq(true)
    expect(policy.toggle_active).to eq(false)
  end


  describe 'strategies' do
    let(:host) {'localhost'}
    let(:method) {'GET'}
    let(:path) {'/'}
    let(:strategy){policy.add_strategy(host, method, path)}

    it 'adds_strategy' do
      expect(strategy).to have_attributes(
                              host: host,
                              method: method,
                              path: path,
                              active: true,
                              options: Screamin::Policy::DEFAULT_EXPIRATION
                          )
      expect(policy.strategies.count).to eq(1)

    end

    it 'removes_strategy' do
      policy.add_strategy(host, method, path)
      expect(policy.strategies.count).to eq(1)
      policy.remove_strategy(host, method, path)
      expect(policy.strategies.count).to eq(0)
    end

    describe 'cache_keys' do
      it 'adds a cache key'  do
        strategy.add_cache_key({})
        expect(strategy.cache_keys.count).to eq(1)
      end
    end
  end
end
