require "grpc"
require "arnoldb/version"
require "arnoldb/proto/arnoldb-protofiles/ruby/arnoldb.rb"
require "arnoldb/proto/arnoldb-protofiles/ruby/arnoldb_services.rb"

module Arnoldb
  autoload :Interface, "arnoldb/interface.rb"
  autoload :Connection, "arnoldb/connection.rb"
  autoload :Mapper, "arnoldb/mapper.rb"
  autoload :References, "arnoldb/generators/references.rb"
  autoload :Migration, "arnoldb/migration.rb"
  autoload :Schema, "arnoldb/schema.rb"

  module Migrations
    autoload :Generator, "arnoldb/migration/generator.rb"
  end

  Arnoldb::Connection.connect
end
