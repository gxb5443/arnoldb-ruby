module Arnoldb
  class Schema
    # @todo need to rename these to be Column and Table and other references
    @@object_types = {}
    @@object_type_ids = {}
    @@fields = {}
    @@field_ids = {}

    # Recreates the cache to mimic the current state of Arnoldb
    def self.build
      p "RECACHING"

      object_types = Arnoldb::Interface.get_all_object_types

      object_types.each do |object_type|
        Arnoldb::Schema.add_table(object_type[:title], object_type[:id])

        fields = Arnoldb::Interface.get_fields(object_type[:id])
        fields.each do |field|
          Arnoldb::Schema.add_column(field[:title], field[:id], object_type[:id])
        end
      end
    end

    # Get an id of a Table or Column from a Title. This searches the reference
    # cache, if no matches are found Arnoldb tries to find a match
    #
    # @todo MAYBE CHANGE it to (title, table, column=nil)
    def self.get_id(type, title, retries: 1)
      result = nil

      if type == "column"
        table, col = title.split(".")
        title = table.upcase + "." + col.downcase
        result = @@fields[title]
      else
        title.upcase!
        result = @@object_types[title]
      end

      if result.nil? && retries > 0
        # REBUILD THE CACHE FROM ARNOLDB
        self.build
        # RETRY get_id CALL
        result = self.get_id(type, title, retries: retries - 1)
      end

      result
    end

    # Get a title of a Table or Column from an Arnoldb_id. This searches
    # the reference cache, if no matches are found Arnoldb tries to find a match
    #
    # @todo MAYBE CHANGE it to (arnoldb_id, table, column=nil)
    def self.get_title(type, arnoldb_id)
      if type == "column"
        @@field_ids[arnoldb_id]
      else
        @@object_type_ids[arnoldb_id]
      end
    end

    # Gets columns for a specified table. This searches the reference cache, if
    # no matches are found Arnoldb tries to find a match
    #
    # @todo SHOULD THINK ABOUT CUSTOM FIELDS
    # @todo naming stuff
    def self.get_columns(table_name)
      columns = {}
      table_name.downcase!

      @@fields.each do |field, id|
        t, column = field.split(".")
        if t.downcase == table_name
          columns[column] = id
        end
      end

      columns
    end

    # Add a table to the schema cache with its associated Arnoldb ID
    def self.add_table(name, table_id)
      # @todo Change this to capitalize format names correctly
      name.upcase!
      @@object_types[name] = table_id
      @@object_type_ids[table_id] = name
    end

    # Add a column to the schema cache with it's associated Arnoldb ID
    def self.add_column(name, column_id, table_id)
      table_name = self.get_title("table", table_id)
      name.downcase!
      @@fields["#{table_name}.#{name}"] = column_id
      @@field_ids[column_id] = "#{table_name}.#{name}"
    end
  end
end
