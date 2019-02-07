require 'spec_helper'

RSpec.describe :screamin do
  let(:component) {described_class}
  before do
    reset_presenters!
    load_presenters(File.expand_path('../../app/web/', __FILE__))
  end

  let(:context) {{}}

  describe 'expand' do
    describe 'all presenters' do
      context 'public' do
        it "expands" do
          expand_component_poms(component, router: TestRouter.new)
        end
      end
    end
  end
end
