require "./spec/spec_helper.rb"

TYPES = {
  integer: 0,
  float: 1,
  string: 2,
}

COP = {
  NONE: 0,
  LT: 1,
  GT: 2,
  EQ: 3
}

describe Arnoldb::Interface do
  let(:connection) { Arnoldb.connect(ENV['TEST_ARNOLDB_ADDRESS']) }
  subject { Arnoldb::Interface.new(connection) }

  describe "#create_object_type" do
    it "creates an object type in arnoldb" do
      object_type_id = subject.create_object_type("Profiles")

      expect(object_type_id).not_to eq(nil)
      expect(object_type_id).not_to eq("")
    end

    let(:empty) { subject.create_object_type("") }

    it "raises an error for empty title" do
      expect { empty }.to raise_error(/Title required/)
    end
  end

  describe "#create_field" do
    before do
      @object_type_id = subject.create_object_type("Profiles")
    end

    context "when correct" do
      it "creates a string field in arnoldb" do
        string_field = subject.create_field(
          @object_type_id,
          "name",
          TYPES[:string]
        )

        expect(string_field).not_to eq(nil)
        expect(string_field).not_to eq("")
      end

      it "creates an integer field in arnoldb" do
        integer_field = subject.create_field(
          @object_type_id,
          "age",
          TYPES[:integer]
        )

        expect(integer_field).not_to eq(nil)
        expect(integer_field).not_to eq("")
      end

      it "creates a float field in arnoldb" do
        float_field = subject.create_field(
          @object_type_id,
          "modifier",
          TYPES[:float]
        )

        expect(float_field).not_to eq(nil)
        expect(float_field).not_to eq("")
      end
    end

    context "when incorrect" do
      let(:empty_obj_type) { subject.create_field("", "last", TYPES[:string]) }
      let(:empty_title) { subject.create_field(@object_type_id, "", TYPES[:string]) }
      let(:wrong_value_type) { subject.create_field(@object_type_id, "value", 99) }

      it "raises an error for empty object type id" do
        expect { empty_obj_type }.to raise_error(/Not a valid uuid/)
      end

      it "raises an error for empty title" do
        expect { empty_title }.to raise_error(/Title required/)
      end

      xit "raises an error for wrong value type" do
        expect { wrong_value_type }.to raise_error(/Wrong type/)
      end
    end
  end

  describe ".create_object" do
    before do
      @object_type_id = subject.create_object_type("Profiles")
    end

    let(:object) { subject.create_object(@object_type_id) }
    let(:object_with_id) do
      subject.create_object(
        @object_type_id,
        "b6785476-146d-43a4-a217-23e186ee7fd3"
      )
    end
    let(:invalid_obj_id) do
      subject.create_object(
        @object_type_id,
        "5"
      )
    end
    let(:invalid_obj_type_id) do
      subject.create_object(
        "5",
      )
    end
    let(:empty_obj_type_id) do
      subject.create_object(
        ""
      )
    end

    it "creates an object in arnoldb" do
      expect(object).not_to eq(nil)
      expect(object).not_to eq("")
    end

    it "creates an object in arnoldb with matching id" do
      expect(object_with_id).to eq("b6785476-146d-43a4-a217-23e186ee7fd3")
    end

    it "raises an error for invalid object id" do
      expect { invalid_obj_id }.to raise_error(/Not a valid uuid/)
    end

    it "raises an error for invalid object type id" do
      expect { invalid_obj_type_id }.to raise_error(/Not a valid uuid/)
    end

    it "raises an error for empty object type id" do
      expect { empty_obj_type_id }.to raise_error(/Not a valid uuid/)
    end
  end

  describe ".create_values" do
    before do
      @object_type_id = subject.create_object_type("Profiles")
      @field_string = subject.create_field(@object_type_id, "name", TYPES[:string])
      @field_integer = subject.create_field(@object_type_id, "age", TYPES[:integer])
      @field_float = subject.create_field(@object_type_id, "modifier", TYPES[:float])
    end

    let(:object) { subject.create_object(@object_type_id) }
    let(:value_set1) do
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
    let(:value_set2) do
      [{
        object_id: object,
        object_type_id: @object_type_id,
        field_id: @field_string,
        value: "old John Kimble"
      },
      {
        object_id: object,
        object_type_id: @object_type_id,
        field_id: @field_integer,
        value: "3000"
      },
      {
        object_id: object,
        object_type_id: @object_type_id,
        field_id: @field_float,
        value: "9.81"
      }]
    end
    let(:value_set3) do
      [{
        object_id: object,
        object_type_id: @object_type_id,
        field_id: @field_string,
        value: "terminator"
      },
      {
        object_id: object,
        object_type_id: @object_type_id,
        field_id: @field_integer,
        value: "-2000"
      },
      {
        object_id: object,
        object_type_id: @object_type_id,
        field_id: @field_float,
        value: "3.14"
      }]
    end
    let(:empty_obj_id) do
      [{
        object_id: "",
        object_type_id: @object_type_id,
        field_id: @field_string,
        value: "empty_obj_id"
      }]
    end
    let(:empty_obj_type_id) do
      [{
        object_id: object,
        object_type_id: "",
        field_id: @field_string,
        value: "empty_obj_type_id"
      }]
    end
    let(:empty_field_id) do
      [{
        object_id: object,
        object_type_id: @object_type_id,
        field_id: "",
        value: "empty_field_id"
      }]
    end
    let(:bad_obj_id) do
      subject.create_values(empty_obj_id)
    end
    let(:bad_obj_type_id) do
      subject.create_values(empty_obj_type_id)
    end
    let(:bad_field_id) do
      subject.create_values(empty_field_id)
    end

    it "creates current values in arnoldb" do
      expected = []
      value_set1.each do |value|
        expected << { id: value[:object_id], value: value[:value] }
      end
      current_values = subject.create_values(value_set1)

      expect(current_values).to match_array(expected)
    end

    it "creates past values in arnoldb" do
      expected = []
      value_set2.each do |value|
        expected << { id: value[:object_id], value: value[:value] }
      end
      past_values = subject.create_values(value_set2, Time.new(2010, 10, 10).to_i)

      expect(past_values).to match_array(expected)
    end

    it "creates future values in arnoldb" do
      expected = []
      value_set3.each do |value|
        expected << { id: value[:object_id], value: value[:value] }
      end
      future_values = subject.create_values(value_set3, (Time.now + (3600 * 24 * 365)).to_i)

      expect(future_values).to match_array(expected)
    end

    it "raises error for object id" do
      expect { bad_obj_id }.to raise_error(/Object Id Not Found/)
    end

    it "raises error for object type id" do
      expect { bad_obj_type_id }.to raise_error(/Field not associated with given Object Type/)
    end

    it "raises error for field id" do
      expect { bad_field_id }.to raise_error(/Field Not Found/)
    end
  end

  # TODO NEED TO FIGURE OUT HOW GET_OBJECT_TYPE SHOULD FUNCTION
  describe ".get_object_type" do
    before do
      @object_type_id = subject.create_object_type("Profiles")
    end

    xit "gets an object type from arnoldb" do
      result = subject.get_object_type("Profiles")

      expect(result).to eq(@object_type_id)
    end

    xit "gets an object type from arnoldb" do
      result = subject.get_object_type("")

      expect(result).to eq("")
    end
  end

  describe ".get_object_types" do
    before do
      @object_type_ids = [
        subject.create_object_type("Profiles"),
        subject.create_object_type("Reports"),
        subject.create_object_type("Jobs"),
      ]
    end

    it "gets all object types from arnoldb" do
      result = subject.get_all_object_types

      expect(result).to include(*@object_types_ids)
    end
  end

  describe ".get_field" do
    before do
      @object_type_id = subject.create_object_type("Profiles")
      @field_string = subject.create_field(
        @object_type_id,
        "first_name",
        TYPES[:string]
      )
    end

    it "gets field from Arnoldb" do
      expected = {
        id: @field_string,
        object_type_id: @object_type_id,
        title: "first_name",
        value_type: :STRING
      }
      result = subject.get_field(@field_string)

      expect(result).to match(expected)
    end
  end

  describe ".get_fields" do
    before do
      @object_type_id = subject.create_object_type("Profiles")
      @field_string = subject.create_field(@object_type_id, "name", TYPES[:string])
      @field_integer = subject.create_field(@object_type_id, "age", TYPES[:integer])
      @field_float = subject.create_field(@object_type_id, "modifier", TYPES[:float])
    end

    let(:fields) do
      [
        { id: @field_string, title: "name", value_type: :STRING },
        { id: @field_integer, title: "age", value_type: :INT32 },
        { id: @field_float, title: "modifier", value_type: :FLOAT32 }
      ]
    end
    let(:bad_obj_type_id) { subject.get_fields("") }

    it "gets fields from arnoldb" do
      result = subject.get_fields(@object_type_id)

      expect(result).to match_array(fields)
    end

    it "raises an error if bad object_type_id" do
      expect { bad_obj_type_id }.to raise_error(/Not a valid uuid/)
    end
  end

  describe ".get_values" do
    before do
      @object_type_id = subject.create_object_type("Profiles")
      @field_string = subject.create_field(@object_type_id, "name", TYPES[:string])
      @field_integer = subject.create_field(@object_type_id, "age", TYPES[:integer])
      @field_float = subject.create_field(@object_type_id, "modifier", TYPES[:float])
      @object = subject.create_object(@object_type_id)
      @fields =  [@field_string, @field_integer, @field_float]
      @objects = [@object]
    end

    let(:value_set1) do
      [{
        object_id: @object,
        object_type_id: @object_type_id,
        field_id: @field_string,
        value: "John Kimble"
      },
      {
        object_id: @object,
        object_type_id: @object_type_id,
        field_id: @field_integer,
        value: "30"
      },
      {
        object_id: @object,
        object_type_id: @object_type_id,
        field_id: @field_float,
        value: "0.5"
      }]
    end
    let(:value_set2) do
      [{
        object_id: @object,
        object_type_id: @object_type_id,
        field_id: @field_string,
        value: "old John Kimble"
      },
      {
        object_id: @object,
        object_type_id: @object_type_id,
        field_id: @field_integer,
        value: "3000"
      },
      {
        object_id: @object,
        object_type_id: @object_type_id,
        field_id: @field_float,
        value: "9.81"
      }]
    end
    let(:value_set3) do
      [{
        object_id: @object,
        object_type_id: @object_type_id,
        field_id: @field_string,
        value: "terminator"
      },
      {
        object_id: @object,
        object_type_id: @object_type_id,
        field_id: @field_integer,
        value: "-2000"
      },
      {
        object_id: @object,
        object_type_id: @object_type_id,
        field_id: @field_float,
        value: "3.14"
      }]
    end
    let(:empty_object_type_id) do
      subject.get_values(
        "",
        @objects,
        @fields
      )
    end
    let(:empty_object_id) do
      subject.get_values(
        @object_type_id,
        [""],
        @fields
      )
    end
    let(:empty_field_id) do
      subject.get_values(
        @object_type_id,
        @objects,
        [""]
      )
    end
    let(:one_empty_object_id) do
      subject.get_values(
        @object_type_id,
        [@object,""],
        @fields
      )
    end

    it "gets current values from arnoldb" do
      expected = []
      value_set1.each do |value|
        expected << { id: value[:object_id], value: value[:value] }
      end
      subject.create_values(value_set1)
      current_values = subject.get_values(@object_type_id, @objects, @fields)

      expect(current_values).to match_array(expected)
    end

    it "gets past values from arnoldb" do
      expected = []
      value_set2.each do |value|
        expected << { id: value[:object_id], value: value[:value] }
      end
      subject.create_values(
        value_set2,
        Time.new(2010, 10, 9).to_i
      )
      past_values = subject.get_values(
        @object_type_id,
        @objects,
        @fields,
        Time.new(2012, 10, 10).to_i
      )

      expect(past_values).to match_array(expected)
    end

    it "gets future values from arnoldb" do
      expected = []
      value_set3.each do |value|
        expected << { id: value[:object_id], value: value[:value] }
      end
      subject.create_values(
        value_set3,
        (Time.now + (3600 * 24 * 366)).to_i
      )
      future_values = subject.get_values(
        @object_type_id,
        @objects,
        @fields,
        (Time.now + (3600 * 24 * 365)).to_i
      )

      expect(future_values).to match_array(expected)
    end

    it "raises an error if bad object_type_id" do
      expect { empty_object_type_id }.to raise_error(/Object Type Not Found/)
    end

    it "raises an error if bad object_id" do
      expect { empty_object_id }.to raise_error(/Not a valid uuid/)
    end

    it "raises an error if bad field_id" do
      expect { empty_field_id }.to raise_error(/Field Not Found/)
    end

    it "raises an error if one bad object_id" do
      expect { one_empty_object_id }.to raise_error(/Not a valid uuid/)
    end
  end

  describe ".get_objects" do
    before do
      @object_type_id = subject.create_object_type("Profiles")
      @field_string = subject.create_field(@object_type_id, "name", TYPES[:string])
      @field_integer = subject.create_field(@object_type_id, "age", TYPES[:integer])
      @field_float = subject.create_field(@object_type_id, "modifier", TYPES[:float])
      @obj_1 = subject.create_object(@object_type_id)
    end

    let(:value_set1) do
      [{
        object_id: @obj_1,
        object_type_id: @object_type_id,
        field_id: @field_string,
        value: "John Kimble"
      },
      {
        object_id: @obj_1,
        object_type_id: @object_type_id,
        field_id: @field_integer,
        value: "30"
      },
      {
        object_id: @obj_1,
        object_type_id: @object_type_id,
        field_id: @field_float,
        value: "0.5"
      }]
    end
    let(:value_set2) do
      [{
        object_id: @obj_1,
        object_type_id: @object_type_id,
        field_id: @field_string,
        value: "old John Kimble"
      },
      {
        object_id: @obj_1,
        object_type_id: @object_type_id,
        field_id: @field_integer,
        value: "3000"
      },
      {
        object_id: @obj_1,
        object_type_id: @object_type_id,
        field_id: @field_float,
        value: "9.81"
      }]
    end
    let(:value_set3) do
      [{
        object_id: @obj_1,
        object_type_id: @object_type_id,
        field_id: @field_string,
        value: "terminator"
      },
      {
        object_id: @obj_1,
        object_type_id: @object_type_id,
        field_id: @field_integer,
        value: "-2000"
      },
      {
        object_id: @obj_1,
        object_type_id: @object_type_id,
        field_id: @field_float,
        value: "3.14"
      }]
    end
    # let(:past_values) do
    #   subject.create_values(value_set2, Time.new(2010, 10, 10).to_i)
    # end
    # let(:future_values) do
    #   subject.create_values(value_set3, (Time.now + (3600 * 24 * 365)).to_i)
    # end
    let(:bad_operator) do
      subject.get_objects(
        @object_type_id,
        [{
          field_id: @field_string,
          value: "John Kimble",
          operator: 99
        }]
      )
    end
    let(:bad_obj_type_id) do
      subject.get_objects(
        "",
        [{
          field_id: @field_string,
          value: "John Kimble",
          operator: COP[:EQ]
        }]
      )
    end
    let(:bad_field_id) do
      subject.get_objects(
        @object_type_id,
        [{
          field_id: "",
          value: "John Kimble",
          operator: COP[:EQ]
        }]
      )
    end

    it "gets current objects from arnoldb" do
      subject.create_values(value_set1)

      result_objects = subject.get_objects(
        @object_type_id,
        [{
          field_id: @field_string,
          value: "John Kimble",
          operator: COP[:EQ]
        }]
      )
      result_object_ids = []
      result_objects.each do |object|
        result_object_ids << object[:id]
      end

      expect(result_object_ids).to include(@obj_1)
    end

    it "raises an error with empty object_type_id" do
      subject.create_values(value_set1)

      expect { bad_obj_type_id }.to raise_error(/Not a valid uuid/)
    end

    it "raises an error with empty field_id" do
      subject.create_values(value_set1)

      expect { bad_field_id }.to raise_error(/Not a valid uuid/)
    end

    it "raises an error with empty operator" do
      subject.create_values(value_set1)

      expect { bad_operator }.to raise_error(/Not a valid operator/)
    end
  end
end
