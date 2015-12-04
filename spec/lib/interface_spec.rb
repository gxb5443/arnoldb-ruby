require './spec/spec_helper.rb'

TYPES = {
  integer: 0,
  float: 1,
  string: 2,
}

describe Arnoldb::Interface do
  describe '.create_object_type' do
    let(:object_type_id) { Arnoldb::Interface.create_object_type("Profiles") }
    let(:empty) { Arnoldb::Interface.create_object_type("") }

    it 'creates an object type in arnoldb' do
      expect(object_type_id).not_to eq(nil)
      expect(object_type_id).not_to eq("")
    end

    it 'raises an error for empty title' do
      expect { empty }.to raise_error(/Title required/)
    end
  end

  describe '.create_field' do
    before(:all) do
      @object_type_id = Arnoldb::Interface.create_object_type("Profiles")
    end

    let(:string_field) { Arnoldb::Interface.create_field(@object_type_id, "name", TYPES[:string]) }
    let(:integer_field) { Arnoldb::Interface.create_field(@object_type_id, "age", TYPES[:integer]) }
    let(:float_field) { Arnoldb::Interface.create_field(@object_type_id, "modifier", TYPES[:float]) }
    let(:empty_obj_type) { Arnoldb::Interface.create_field("", "last", TYPES[:string]) }
    let(:empty_title) { Arnoldb::Interface.create_field(@object_type_id, "", TYPES[:string]) }
    let(:wrong_value_type) { Arnoldb::Interface.create_field(@object_type_id, "value", 99) }

    it 'creates a string field in arnoldb' do
      expect(string_field).not_to eq(nil)
      expect(string_field).not_to eq("")
    end

    it 'creates an integer field in arnoldb' do
      expect(integer_field).not_to eq(nil)
      expect(integer_field).not_to eq("")
    end

    it 'creates a float field in arnoldb' do
      expect(float_field).not_to eq(nil)
      expect(float_field).not_to eq("")
    end

    it 'raises an error for empty object type id' do
      expect { empty_obj_type }.to raise_error(/Not a valid uuid/)
    end

    it 'raises an error for empty title' do
      expect { empty_title }.to raise_error(/Title required/)
    end

    xit 'raises an error for wrong value type' do
      expect { wrong_value_type }.to raise_error(/Wrong type/)
    end
  end

  describe '.create_object' do
    before(:all) do
      @object_type_id = Arnoldb::Interface.create_object_type("Profiles")
    end

    let(:object) { Arnoldb::Interface.create_object(@object_type_id) }
    let(:object_with_id) do
      Arnoldb::Interface.create_object(
        @object_type_id,
        "b6785476-146d-43a4-a217-23e186ee7fd3"
      )
    end
    let(:invalid_obj_id) do
      Arnoldb::Interface.create_object(
        @object_type_id,
        "5"
      )
    end
    let(:invalid_obj_type_id) do
      Arnoldb::Interface.create_object(
        "5",
      )
    end
    let(:empty_obj_type_id) do
      Arnoldb::Interface.create_object(
        ""
      )
    end

    it 'creates an object in arnoldb' do
      expect(object).not_to eq(nil)
      expect(object).not_to eq("")
    end

    it 'creates an object in arnoldb with matching id' do
      expect(object_with_id).not_to eq(nil)
      expect(object_with_id).not_to eq("")
      expect(object_with_id).to eq("b6785476-146d-43a4-a217-23e186ee7fd3")
    end

    it 'raises an error for invalid object id' do
      expect { invalid_obj_id }.to raise_error(/Not a valid uuid/)
    end

    it 'raises an error for invalid object type id' do
      expect { invalid_obj_type_id }.to raise_error(/Not a valid uuid/)
    end

    it 'raises an error for empty object type id' do
      expect { empty_obj_type_id }.to raise_error(/Not a valid uuid/)
    end
  end

  describe '.create_values' do
    before(:all) do
      @object_type_id = Arnoldb::Interface.create_object_type("Profiles")
      @field_string = Arnoldb::Interface.create_field(@object_type_id, "name", TYPES[:string])
      @field_integer = Arnoldb::Interface.create_field(@object_type_id, "age", TYPES[:integer])
      @field_float = Arnoldb::Interface.create_field(@object_type_id, "modifier", TYPES[:float])
    end

    let(:object) { Arnoldb::Interface.create_object(@object_type_id) }
    let(:values) do
      [{
        object_id: object,
        object_type_id: @object_type_id,
        field_id: @field_string,
        value: "John Kimble"
      },
      {
        object_id: object,
        object_type_id: @object_type_id,
        field_id: @field_integer,
        value: "30"
      },
      {
        object_id: object,
        object_type_id: @object_type_id,
        field_id: @field_float,
        value: "0.5"
      }]
    end
    let(:current_values) do
      Arnoldb::Interface.create_values(values)
    end

    it 'creates current values in arnoldb' do
      expected = []
      values.each do |value|
        expected << { id: value[:object_id], value: value[:value] }
      end

      expect(current_values).not_to eq(nil)
      expect(current_values).not_to eq("")
      expect(current_values).to match_array(expected)
    end
  end

  describe '.get_object_type' do
    it 'gets an object type from arnoldb'
  end

  describe '.get_object_types' do
    it 'gets all object types from arnoldb'
  end

  describe '.get_objects' do
    it 'gets objects from arnoldb'
  end

  describe '.get_fields' do
    it 'gets fields from arnoldb'
  end

  describe '.get_values' do
    it 'gets values from arnoldb'
  end

  describe '.connection' do

  end
end
