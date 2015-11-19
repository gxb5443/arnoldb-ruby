require "grpc"
require "arnoldb/version"
require "arnoldb/proto/arnoldb-protofiles/ruby/arnoldb.rb"
require "arnoldb/proto/arnoldb-protofiles/ruby/arnoldb_services.rb"

module Arnoldb
  autoload :Interface, "arnoldb/interface.rb"
  autoload :Connection, "arnoldb/connection.rb"

  Arnoldb::Connection.connect
end
