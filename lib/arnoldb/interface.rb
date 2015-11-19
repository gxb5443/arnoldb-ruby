require 'colorize'

module Arnoldb
  class Interface
    # Creates a Table in Arnoldb
    # @param [String] title the title of the Table to be created
    # @return [String] returns the associated Arnoldb ID for the created Table
    #
    # @todo CHANGE NAMING TO TABLE AND COLUMN
    def self.create_object_type(title)
      object_type_id = connection.set_object_type(Proto::ObjectType.new(title: title))["id"]
      Arnoldb::Schema.add_table(title, object_type_id)

      object_type_id
    end

    # Creates a Column in Arnoldb
    # @param [String] object_type_id the Table's Arnoldb ID
    # @param [String] title the title of the Column to be created
    # @param [String] value_type the data type for the Column
    # @return [String] returns the associated Arnoldb ID for the created Column
    #
    # @todo CHANGE NAMING TO TABLE AND COLUMN
    def self.create_field(object_type_id, title, value_type)
      field_id = connection.set_field(Proto::Field.new(object_type_id: object_type_id, title: title, value_type: value_type))["id"]
      Arnoldb::Schema.add_column(title, field_id, object_type_id)

      field_id
    end

    # Creates an Object in Arnoldb
    # @param [String] object_type_id the Table's Arnoldb ID
    # @return [String] returns the associated Arnoldb ID for the created Object
    #
    # @todo CHANGE NAMING TO TABLE AND COLUMN
    def self.create_object(object_type_id)
      begin_time = Time.now
      begin
        response = connection.set_object(Proto::Object.new(object_type_id: object_type_id))["id"]
      rescue Exception => e
        puts "ARNOLDB:CreateObject WARNING: ".yellow + "#{ e }"

        return false
      end
      end_time = Time.now
      puts "ARNOLDB:#{ Arnoldb::Schema.get_title("table", object_type_id) } Created (#{ ((end_time - begin_time)*1000).round(2) }ms) ".green + "#{ response.inspect }"

      response
    end

    # Creates values in Arnoldb for specific Object Columns
    # @param [Array<Hash>] values the values which will be created in Arnoldb
    # @option values [String] :object_id the Arnoldb ID for the Object
    # @option values [String] :field_id the Arnoldb ID for the Column
    # @option values [String] :value the new value
    # @param [Integer] effective_date the effective date that the value will
    # take effect
    #
    # @todo FIGURE OUT WHAT RETURNS??
    def self.create_values(values, effective_date)
      p "creating values"
      values_messages = []
      values.each do |value|
        field = Proto::Field.new(id: value[:field_id], object_type_id: value[:object_type_id])
        values_messages << Proto::Value.new(object_id: value[:object_id], value: value[:value].to_s, field: field)
      end

      begin_time = Time.now
      begin
        response = connection.set_values(Proto::Values.new(values: values_messages, date: effective_date))
      rescue Exception => e
        puts "ARNOLDB:SetValues WARNING: ".yellow + "#{ e }"

        return false
      end
      end_time = Time.now
      puts "ARNOLDB:#{ Arnoldb::Schema.get_title("table", response.object_type_id) } (#{ ((end_time - begin_time)*1000).round(2) }ms) ".green + "#{ response.inspect }"

      response
    end

    # Gets the Arnoldb ID of specific Table
    # @param [String] title the title of the Table
    # @return [String, nil] the Arnoldb ID for the Table if found
    #
    # @todo finish ARNOLDB to allow for titles to be sent
    def self.get_object_type(title)
      p "getting object_type"
      connection.get_object_type(Proto::ObjectType.new(title: title))[:id]
    end

    # @todo WRITE DOCS
    # @todo finish!!
    def self.get_all_object_types
      p "getting all object_types"

      object_types = []
      response = connection.get_all_object_types(Proto::Empty.new)
      response.object_types.each do |object_type|
        object_types << { id: object_type.id, title: object_type.title }
      end

      object_types
    end

    # @todo WRITE DOCS
    # @todo FINISH!!!
    def self.get_fields(object_type_id)
      p "getting all fields"

      fields = []
      response = connection.get_fields(Proto::ObjectType.new(id: object_type_id))
      response.fields.each do |field|
        fields << { id: field.id, title: field.title, value_type: field.value_type }
      end

      fields
    end

    # Gets Objects from Arnoldb which match specific Query Clauses for a given
    # date.
    # @param [String] object_type_id the Arnoldb ID for the Table
    # @param [Array<Hash>] clauses the clauses for querying for Objects
    # @param [DateTime] date the date for what version of the Objects being
    # queried
    # @return [Array<Hash>] Objects which satisfy the clauses
    def self.get_objects(object_type_id, clauses, date, arnoldb_objects = false)
      p "getting objects"

      if clauses.count > 1
        leaves = []
        clauses.each do |clause|
          leaf = Proto::Objects::Clause::Leaf.new(
            field: clause[:field_id],
            value: clause[:value].to_s,
            cop: clause[:operator]
          )
          leaf = Proto::Objects::Clause.new(l: leaf)
          leaves << leaf
        end

        branches = []
        while leaves.count > 0 do
          left = leaves.pop
          right = branches.empty? ? leaves.pop : branches.pop

          branch = Proto::Objects::Clause::Branch.new(lop: 1, left: left, right: right)
          branch = Proto::Objects::Clause.new(b: branch)
          branches << branch
        end

        # @todo HARD CODED LOGICAL OPERATOR AS "1" WHICH is AND
        clause_messages = [Proto::Objects::Clause.new(b: branches.pop)]
      elsif clauses.count == 1
        clause = clauses.pop
        leaf = Proto::Objects::Clause::Leaf.new(
          field: clause[:field_id],
          value: clause[:value].to_s,
          cop: clause[:operator]
        )
        clause_messages = [Proto::Objects::Clause.new(l: leaf)]
      else
        clause_messages = []
      end

      objects = []
      objects_query = Proto::Objects.new(object_type_id: object_type_id, clauses: clause_messages, date: date.to_i)
      begin_time = Time.now
      begin
        response = connection.get_objects(objects_query)
      rescue Exception => e
        puts "ARNOLDB:GetObjects WARNING: ".yellow + "#{ e }"

        return objects = []
      end
      end_time = Time.now

      puts "ARNOLDB:#{ response.object_type_title.capitalize } (#{ ((end_time - begin_time)*1000).round(2) }ms) ".green + "#{ objects_query.inspect }"
      $stdout.flush

      if arnoldb_objects
        return response.objects
      end
      begin_time = Time.now
      response.objects.each do |object|
        objects << Arnoldb::Mapper.convert(object)
      end
      end_time = Time.now
      puts "ARNOLDB:Mapping (#{ ((end_time - begin_time)*1000).round(2) }ms) ".green + "#{objects.count} objects mapped"
      $stdout.flush

      objects
    end

    # Makes a connection to Arnoldb
    #
    # @todo make arguments for client and server addr
    # @todo MIGHT CLEAN THIS UP?
    def self.connection
      server = Arnoldb::Connection.connect
      connection = server.connection

      connection
    end
  end
end