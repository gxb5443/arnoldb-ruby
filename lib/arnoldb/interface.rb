require 'colorize'

module Arnoldb
  class Interface
    # Creates a Table in Arnoldb
    # @param [String] title the title of the Table to be created
    # @return [String] returns the associated Arnoldb ID for the created Table
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
    def self.create_field(object_type_id, title, value_type)
      field_id = connection.set_field(Proto::Field.new(object_type_id: object_type_id, title: title, value_type: value_type))["id"]
      Arnoldb::Schema.add_column(title, field_id, object_type_id)

      field_id
    end

    # Creates an Object in Arnoldb
    # @param [String] object_type_id the Table's Arnoldb ID
    # @param [String] object_id the Object's Arnoldb ID used for setting during
    # migrations
    # @return [String] returns the associated Arnoldb ID for the created Object
    def self.create_object(object_type_id, object_id = "")
      response = connection.set_object(Proto::Object.new(object_type_id: object_type_id, id: object_id))["id"]

      response
    end

    # Creates values in Arnoldb for specific Object Columns
    # @param [Array<Hash>] values the values which will be created in Arnoldb
    # @option values [String] :object_id the Arnoldb ID for the Object
    # @option values [String] :object_type_id the Arnoldb ID for the Object Type
    # @option values [String] :field_id the Arnoldb ID for the Column
    # @option values [String] :value the new value
    # @param [Integer] effective_date the effective date that the value will
    # take effect
    # @return [Array<Hash>] objects the object IDs matched with the new values
    # in Arnoldb
    # @option objects [String] :id the Arnoldb ID for an Object
    # @option objects [String] :value the value assigned to an Object
    def self.create_values(values, effective_date = 0)
      values_messages = []
      values.each do |value|
        field = Proto::Field.new(id: value[:field_id], object_type_id: value[:object_type_id])
        values_messages << Proto::Value.new(object_id: value[:object_id], value: value[:value].to_s, field: field)
      end

      response = connection.set_values(Proto::Values.new(values: values_messages, date: effective_date))
      objects = []
      response.values.each do |value|
        objects << { id: value["object_id"], value: value["value"] }
      end

      objects
    end

    # Gets the Arnoldb ID of specific Object Type
    # @param [String] title the title of the Object Type
    # @return [String, nil] the Arnoldb ID for the Object Type if found
    #
    # @todo finish ARNOLDB to allow for titles to be sent
    def self.get_object_type(title)
      connection.get_object_type(Proto::ObjectType.new(title: title))[:id]
    end

    # Gets the Arnoldb IDs for all of the Object Types in Arnoldb
    # @return [Array<Hash>] object_types the Object Type IDs and titles
    # @option object_types [String] :id the Arnoldb ID for an Object Type
    # @option object_types [String] :title the title for an Object Type
    def self.get_all_object_types
      object_types = []
      response = connection.get_all_object_types(Proto::Empty.new)
      response.object_types.each do |object_type|
        object_types << { id: object_type.id, title: object_type.title }
      end

      object_types
    end

    # Gets a Field from its Arnoldb ID
    # @param [String] field_id the Arnoldb ID for the Field
    # @return [Hash] fields the Field ID, Object Type ID, title, and value type
    # @option fields [String] :id the Arnoldb ID for a Field
    # @option fields [String] :title the title for a Field
    # @option fields [String] :value_type the value type for a Field
    # @option fields [String] :object_type_id the Object Type for a Field
    def self.get_field(field_id)
      field = connection.get_field(Proto::Field.new(id: field_id))
      result = {
        id: field.id,
        title: field.title,
        value_type: field.value_type,
        object_type_id: field.object_type_id
      }

      result
    end

    # Gets Fields for an Object Type from Arnoldb
    # @param [String] object_type_id the Arnoldb ID for the Table
    # @return [Array<Hash>] fields the Field IDs, titles, and value types
    # @option fields [String] :id the Arnoldb ID for a Field
    # @option fields [String] :title the title for a Field
    # @option fields [String] :value_type the value type for a Field
    def self.get_fields(object_type_id)
      fields = []
      response = connection.get_fields(Proto::ObjectType.new(id: object_type_id))
      response.fields.each do |field|
        fields << { id: field.id, title: field.title, value_type: field.value_type }
      end

      fields
    end

    # Gets Values from Arnoldb which match the given Object Type ID, Object IDs,
    # and Field IDs
    # @param [String] object_type_id the Arnoldb ID for the Table
    # @param [Array<String>] object_ids the Arnoldb IDs for the desired Objects
    # @param [Array<String>] field_ids the Arnoldb IDS for the desired Fields
    # @param [DateTime] date the date for what version of the Values being
    # queried
    # @return [Array<Hash>] Values for the desired Objects and Fields
    def self.get_values(object_type_id, object_ids, field_ids, date = 0)
      objects = []
      object_ids.each do |object_id|
        objects << Proto::Object.new(id: object_id)
      end

      fields = []
      field_ids.each do |field_id|
        fields << Proto::Field.new(id: field_id)
      end

      values = Proto::Values.new(
        object_type_id: object_type_id,
        object_ids: objects,
        fields: fields,
        date: date
      )
      response = connection.get_values(values)
      result = []
      response.values.each do |value|
        result << { id: value["object_id"], value: value["value"] }
      end

      result
    end

    # Gets Objects from Arnoldb which match specific Query Clauses for a given
    # date.
    # @param [String] object_type_id the Arnoldb ID for the Table
    # @param [Array<Hash>] clauses the clauses for querying for Objects
    # @param [DateTime] date the date for what version of the Objects being
    # queried
    # @return [Array<Hash>] Objects which satisfy the clauses
    def self.get_objects(object_type_id, clauses, date = 0)
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

        # @todo HARD CODED LOGICAL OPERATOR AS "1" WHICH is AND
          branch = Proto::Objects::Clause::Branch.new(lop: 1, left: left, right: right)
          branch = Proto::Objects::Clause.new(b: branch)
          branches << branch
        end

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

      objects_query = Proto::Objects.new(object_type_id: object_type_id, clauses: clause_messages, date: date.to_i)

      response = connection.get_objects(objects_query)
      objects = []
      response.objects.each do |object|
        values = []
        object.values.each do |value|
          values << {
            value: value["value"],
            field_id: value.field["id"],
            title: value.field["title"],
            value_type: value.field["value_type"]
          }
        end
        objects << {
          id: object["id"],
          object_type_id: object["object_type_id"],
          values: values
        }
      end

      objects
    end

    private

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
