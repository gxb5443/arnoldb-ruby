module Arnoldb
  class Connection
    @@connection = nil

    # CLEAN ALL OF THIS UP
    # @private
    def initialize
      @client = client
      @server_address = server_address
    end

    # @return the connection to the server
    def self.connect
      @@connection ||= self.new
    end

    # @todo MIGHT NEED TO MAKE THIS BETTER AND ALLOW FOR MULTIPLE CONNECTIONS?
    def connection
      @@connection.client
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
