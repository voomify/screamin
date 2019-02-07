require 'spec_helper'
require 'screamin/entities/analysis'
require 'screamin/entities/trace'
require 'screamin/entities/policy'
require 'rack'
require 'securerandom'

RSpec.describe Screamin::Analysis do
  let(:analysis) {described_class.new(nil, trace)}
  let(:trace) {Screamin::Trace.new([[Time.now, {'REQUEST_METHOD'=>method, 'PATH_INFO'=>path, 'SERVER_NAME'=>host}, {}],[Time.now, :miss, 200, {}, SecureRandom.hex(4)]])}
  let(:method) {'GET'}
  let(:host) {'localhost'}
  let(:path) {'/'}

  describe 'strategies' do
    let(:policy) {Screamin::Policy.new}
    let(:strategy) {policy.request_strategy(host,method,path)}

    before do
      policy.add_strategy(host, method, path)
    end

    it 'behaves like a request' do
      expect(strategy.matches?(analysis)).to eq(true)
    end
  end
end
