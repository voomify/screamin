module Screamin
  module Debug
    def debug(*msgs)
      return unless ENV['DEBUG_SCREAMIN']=='true'
      msgs.each do |msg|
        puts msg
      end
    end
  end
end
