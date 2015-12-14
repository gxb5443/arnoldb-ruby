module Arnoldb
  def self.connection
    @connection ||= Connection.new
    @connection.client
  end

  # @return the connection to the server
  def self.connect
    yield connection
  end

  class Connection
    attr_accessor :client

    # CLEAN ALL OF THIS UP
    # @private
    def initialize
      @client = client
      @server_address = server_address
    end

    def client
      @client ||= Proto::DatastoreActions::Stub.new(self.server_address)
    end

    # @todo UPDATE THIS TO GET DEFAULT FROM CONFIG FILE??
    def server_address
      @server_address ||= "#{ ENV["ARNOLDB_ADDR"] }:#{ ENV["ARNOLDB_PORT"] }"
    end
  end
end
