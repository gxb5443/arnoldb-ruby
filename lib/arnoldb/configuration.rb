require 'redis'

module Arnoldb
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configuration=(config)
    @configuration = config
  end

  def self.configure
    yield configuration
  end

  class Configuration
    # TODO ADD ARNOLDB CONNECTION HERE?
    attr_accessor :redis

    def initialize
      @redis = Redis.new(url: ENV["REDIS_URL"])
    end
  end
end
