require 'chronic'
require 'oauth'

module Weather
  class Utils
    class << self
      # Attempts to convert passed text into a Time object
      #
      # Returns a Time object or nil
      def parse_time(text = '')
        if text == ''
          return nil
        end

        begin
          Time.parse text
        rescue ArgumentError
          Chronic.parse text
        end
      end

      # Attempts to authenticate using the YQL servers using OAuth1
      #
      # Returns an instance of OAuth::AccessToken
      def get_access_token(url, consumer_key, consumer_secret)
        consumer = OAuth::Consumer.new(consumer_key, consumer_secret, { site: url })
        access_token = OAuth::AccessToken.new(consumer)
        access_token
      end
    end
  end
end
