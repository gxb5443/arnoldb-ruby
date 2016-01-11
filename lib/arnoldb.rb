require "grpc"
require "arnoldb/version"
require "arnoldb/proto/arnoldb-protofiles/ruby/arnoldb.rb"
require "arnoldb/proto/arnoldb-protofiles/ruby/arnoldb_services.rb"

module Arnoldb
  autoload :Base, "arnoldb/base.rb"

  def self.connect(arnoldb_address)
    if ENV["ARNOLDB_TLS"] == "ENABLE"
      credentials = GRPC::Core::Credentials.new(
        File.read("./keys/server.crt"),
        File.read("./keys/client.key"),
        File.read("./keys/client.crt")
      )

      Proto::DatastoreActions::Stub.new(arnoldb_address, creds: credentials)
    else
      Proto::DatastoreActions::Stub.new(arnoldb_address)
    end
  end
end
