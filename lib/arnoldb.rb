require "grpc"
require "arnoldb/version"
require "arnoldb/proto/arnoldb-protofiles/ruby/arnoldb.rb"
require "arnoldb/proto/arnoldb-protofiles/ruby/arnoldb_services.rb"
require "arnoldb/connection.rb"

module Arnoldb
  autoload :Interface, "arnoldb/interface.rb"
  autoload :Schema, "arnoldb/schema.rb"
end
