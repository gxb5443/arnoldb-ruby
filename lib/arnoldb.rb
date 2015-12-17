require "grpc"
require "arnoldb/version"
require "arnoldb/proto/arnoldb-protofiles/ruby/arnoldb.rb"
require "arnoldb/proto/arnoldb-protofiles/ruby/arnoldb_services.rb"

module Arnoldb
  autoload :Interface, "arnoldb/interface.rb"

  def self.connect(arnoldb_address)
    Proto::DatastoreActions::Stub.new(arnoldb_address)
  end
end
