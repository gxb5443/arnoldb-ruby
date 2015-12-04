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

    it 'raises an error for wrong value type' do
      expect { wrong_value_type }.to raise_error(/Not a valid uuid/)
    end
  end

  describe '.create_object' do
    it 'creates an object in arnoldb'
  end

  describe '.create_values' do
    it 'creates a values in arnoldb'
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
