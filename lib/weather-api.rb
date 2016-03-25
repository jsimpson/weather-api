require 'net/http'
require 'json'
require 'map'
require 'oauth'

require 'weather-api/astronomy'
require 'weather-api/atmosphere'
require 'weather-api/condition'
require 'weather-api/forecast'
require 'weather-api/image'
require 'weather-api/location'
require 'weather-api/response'
require 'weather-api/units'
require 'weather-api/utils'
require 'weather-api/version'
require 'weather-api/wind'

module Weather
  class << self
    # Yahoo! Weather info endpoint
    ROOT = 'https://query.yahooapis.com/'

    # YQL public endpoint
    YQL_PUBLIC_ENDPOINT = 'v1/public/yql'

    # YQL Oauth1 endpoint
    YQL_OAUTH_ENDPOINT = 'v1/yql'

    # Public: Looks up current weather information using WOEID
    #
    # consumer_key - OAuth key provided by Yahoo! for the
    #                registered application.
    #
    # consumer_secret - OAuth secret provided by Yahoo for the
    #                   registered application.
    #
    # woeid - Int - Where On Earth IDentifier -- unique ID for
    #         location to get weather data for. To find
    #         a WOEID, refer to Yahoo!'s documentation
    #         at http://developer.yahoo.com/weather/
    #
    # unit - system of measurement to use. Two acceptable inputs:
    #        'c' - Celsius/Metric measurements
    #        'f' - Fahrenheit/Imperial measurements.
    #
    #        To make this easier, you can use the Weather::Units::FAHRENHEIT and
    #        Weather::Units::CELSIUS constants. Defaults to Celsius
    #
    # Returns a Weather::Response object containing forecast
    def lookup(woeid, unit = Units::CELSIUS, consumer_key = nil, consumer_secret = nil)
      acceptable_units = [Units::CELSIUS, Units::FAHRENHEIT]
      unit = Units::CELSIUS unless acceptable_units.include?(unit)

      query = "select%20*%20from%20weather.forecast%20where%20woeid%3D#{woeid}%20and%20u%3D'#{unit}'"

      unless consumer_key.nil? && consumer_secret.nil?
        url = ROOT + YQL_OAUTH_ENDPOINT
        access_token = Utils.get_access_token(url, consumer_key, consumer_secret)
      else
        url = ROOT + YQL_PUBLIC_ENDPOINT
      end

      url += "?q=#{query}&format=json"
      doc = get_response url, access_token

      Response.new woeid, url, doc
    end

    private

    def get_response url, access_token = nil
      begin
        unless access_token.nil?
          response = access_token.request(:get, url).body.to_s
        else
          response = Net::HTTP.get_response(Addressable::URI.parse(url)).body.to_s
        end
      rescue => e
        raise "Failed to get weather [url=#{url}, e=#{e}]."
      end

      begin
        response = Map.new(JSON.parse(response))['query']['results']['channel']
      rescue => e
        raise "Failed to retrieve results [url=#{url}, e=#{e}]."
      end

      if response.nil? or response.title.match(/error/i)
        raise "Failed to get weather [url=#{url}]."
      end

      response
    end
  end
end
