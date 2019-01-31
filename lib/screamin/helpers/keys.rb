module Screamin
  module KeyHelpers
    def build_key(*k, keys_klass: Keys)
      @keys ||= keys_klass.new
      @keys.build(*k)
    end

    class Keys
      def build(*keys)
        "#{keys.join(':')}"
      end
    end
  end
end
