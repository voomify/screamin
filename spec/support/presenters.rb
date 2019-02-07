require 'voom-presenters'

class TestRouter
  attr_reader :base_url

  def url(command: nil, render: nil, context:)
    nil
  end
end

Voom::Presenters::Settings.configure do |config|
  config.presenters.deep_freeze = false
end

module Support
  module Loader
    def load_presenters(root)
      Voom::Presenters::App.load('.', root)
    end

    alias load_dependencies load_presenters

    def reset_presenters!
      Voom::Presenters::App.reset!
    end


    # Expands all presenters in a given component namespace
    # Take the component namespace (as a string or symbol)
    # Options:
    #   select: takes a lambda for selecting the presenters to test
    #   include: array of the components to include (as symbols)
    #   exclude: array of the components to include (as symbols)
    # Optionally takes a block that is padded the pom from the expansion. This allow your tests
    # To add additional expectations
    # For example:
    #   expand_component_poms(:sales_reps) do |pom|
    #     expect(pom.components.first.id).to eq(:some_id)
    #   end
    def expand_component_poms(component,
                              router: nil,
                              include: :all,
                              exclude: [],
                              select: ->(key, component_, include_, exclude_) {
                                presenter = key.sub("#{component_}:", '').to_sym
                                key.start_with?(component_.to_s) &&
                                    (include == :all || Array(include_).include?(presenter)) &&
                                    !(exclude_.include?(presenter))
                              },
                              &block)
      keys = Voom::Presenters::App.keys
      keys.select {|k| select.call(k, component, include, exclude)}.each do |key|
        puts "expanding: #{key}"
        current_context = :"context_#{key.sub("#{component}:", '')}"
        context = self.respond_to?(current_context) ? self.send(current_context) : self.context
        expect {@pom = Voom::Presenters::App[key].call.expand(router: router,
                                                              context: context)}.not_to raise_error
        block.call(@pom) if block
      end
    end
  end
end

RSpec.configure do |c|
  c.include Support::Loader
end

