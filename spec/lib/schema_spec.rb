require "./spec/spec_helper.rb"

describe Arnoldb::Schema do
  describe ".build" do
    before(:all) do
      Arnoldb::Schema.class_variable_set(:@@object_types, {})
      Arnoldb::Schema.class_variable_set(:@@object_type_ids, {})
      Arnoldb::Schema.class_variable_set(:@@fields, {})
      Arnoldb::Schema.class_variable_set(:@@field_ids, {})
    end

    it "gets all object types from Arnoldb" do
      object_types = [
        { id: "222", title: "Animals" }
      ]
      fields = [
        { id: "2220", title: "name" },
        { id: "3331", title: "age" }
      ]

      allow(Arnoldb::Interface).to receive(:get_all_object_types) { object_types }
      allow(Arnoldb::Interface).to receive(:get_fields) { fields }
      expect(Arnoldb::Interface).to receive(:get_all_object_types)
      Arnoldb::Schema.build

      expect(Arnoldb::Schema.class_variable_get(:@@object_types)).to match("ANIMALS" => "222")
      expect(Arnoldb::Schema.class_variable_get(:@@object_type_ids)).to match("222" => "ANIMALS")
      expect(Arnoldb::Schema.class_variable_get(:@@fields)).to match("ANIMALS.name" => "2220", "ANIMALS.age" => "3331")
    end
  end

  describe ".get_id" do
    before(:all) do
      Arnoldb::Schema.class_variable_set(:@@object_types, {})
      Arnoldb::Schema.class_variable_set(:@@object_type_ids, {})
      Arnoldb::Schema.class_variable_set(:@@fields, {})
      Arnoldb::Schema.class_variable_set(:@@field_ids, {})
    end

    after(:each) do
      Arnoldb::Schema.class_variable_set(:@@object_types, {})
      Arnoldb::Schema.class_variable_set(:@@object_type_ids, {})
      Arnoldb::Schema.class_variable_set(:@@fields, {})
      Arnoldb::Schema.class_variable_set(:@@field_ids, {})
    end

    context "when looking for object types" do
      it "gets the correct id" do
        Arnoldb::Schema.class_variable_set(
          :@@object_types,
          {
            "TOKENS" => "11110",
            "HASHES" => "11111",
          }
        )

        expect(Arnoldb::Schema.get_id("table", "TOKENS")).to eq("11110")
      end

      it "normalizes titles" do
        Arnoldb::Schema.class_variable_set(
          :@@object_types,
          {
            "TOKENS" => "11110",
            "HASHES" => "11111",
          }
        )

        expect(Arnoldb::Schema.get_id("table", "toKenS")).to eq("11110")
      end

      it "rebuilds the cache if not found" do
        expect(Arnoldb::Schema).to receive(:build)
        Arnoldb::Schema.get_id("table", "MISSING")
      end
    end

    context "when looking for fields" do
      it "gets the correct id" do
        Arnoldb::Schema.class_variable_set(
          :@@fields,
          {
            "TOKENS.id" => "314",
            "TOKENS.name" => "315",
            "HASHES.id" => "316",
            "HASHES.name" => "317",
          }
        )

        expect(Arnoldb::Schema.get_id("column", "TOKENS.id")).to eq("314")
      end

      it "normalize titles" do
        Arnoldb::Schema.class_variable_set(
          :@@fields,
          {
            "TOKENS.id" => "314",
            "TOKENS.name" => "315",
            "HASHES.id" => "316",
            "HASHES.name" => "317",
          }
        )

        expect(Arnoldb::Schema.get_id("column", "TokENs.ID")).to eq("314")
      end
    end
  end

  describe ".get_title" do
    before(:all) {
      Arnoldb::Schema.class_variable_set(:@@object_type_ids, {})
      Arnoldb::Schema.class_variable_set(:@@field_ids, {})
    }

    after(:each) {
      Arnoldb::Schema.class_variable_set(:@@object_type_ids, {})
      Arnoldb::Schema.class_variable_set(:@@field_ids, {})
    }

    it "gets the title of a column" do
      Arnoldb::Schema.class_variable_set(
        :@@field_ids,
        {
          "555" => "SIGN.number",
        }
      )

      expect(Arnoldb::Schema.get_title("column", "555")).to eq("SIGN.number")
    end

    it "gets the title of a table" do
      Arnoldb::Schema.class_variable_set(
        :@@object_type_ids,
        {
          "111" => "ADMINS",
        }
      )

      expect(Arnoldb::Schema.get_title("table", "111")).to eq("ADMINS")
    end
  end

  describe ".get_columns" do
    before(:all) {
      Arnoldb::Schema.class_variable_set(:@@fields, {})
      Arnoldb::Schema.class_variable_set(:@@field_ids, {})
    }

    after(:each) {
      Arnoldb::Schema.class_variable_set(:@@fields, {})
      Arnoldb::Schema.class_variable_set(:@@field_ids, {})
    }

    it "finds all columns for a table" do
      Arnoldb::Schema.class_variable_set(
        :@@fields,
        {
          "GHOSTS.operation_id" => "007",
          "GHOSTS.weapon" => "008",
          "GHOSTS.kias" => "009",
          "GHOSTS.id" => "010",
        }
      )
      expected = {
        "operation_id" => "007",
        "weapon" => "008",
        "kias" => "009",
        "id" => "010",
      }

      expect(Arnoldb::Schema.get_columns("GHOSTS")).to match(expected)
    end

    it "normalize title" do
      Arnoldb::Schema.class_variable_set(
        :@@fields,
        {
          "COUNTRY.operatives" => "080",
          "COUNTRY.lives" => "090",
          "COUNTRY.reach" => "100",
          "COUNTRY.id" => "110",
        }
      )
      expected = {
        "operatives" => "080",
        "lives" => "090",
        "reach" => "100",
        "id" => "110",
      }

      expect(Arnoldb::Schema.get_columns("CouNtry")).to match(expected)
    end
  end

  describe ".add_table" do
    before(:all) do
      Arnoldb::Schema.class_variable_set(:@@object_types, {})
      Arnoldb::Schema.class_variable_set(:@@object_type_ids, {})
    end

    after(:each) do
      Arnoldb::Schema.class_variable_set(:@@object_types, {})
      Arnoldb::Schema.class_variable_set(:@@object_type_ids, {})
    end

    it "adds an object type" do
      Arnoldb::Schema.add_table("ARTICLES", "abc")

      expect(Arnoldb::Schema.class_variable_get(:@@object_types)).to include("ARTICLES" => "abc")
      expect(Arnoldb::Schema.class_variable_get(:@@object_type_ids)).to include("abc" => "ARTICLES")
    end

    it "normalizes titles" do
      Arnoldb::Schema.add_table("people", "def")
      Arnoldb::Schema.add_table("OfFices_ArounD", "ghi")

      expect(Arnoldb::Schema.class_variable_get(:@@object_types)).to include("PEOPLE" => "def")
      expect(Arnoldb::Schema.class_variable_get(:@@object_type_ids)).to include("def" => "PEOPLE")
      expect(Arnoldb::Schema.class_variable_get(:@@object_types)).to include("OFFICES_AROUND" => "ghi")
      expect(Arnoldb::Schema.class_variable_get(:@@object_type_ids)).to include("ghi" => "OFFICES_AROUND")
    end
  end

  describe ".add_column" do
    before(:all) {
      Arnoldb::Schema.class_variable_set(:@@fields, {})
      Arnoldb::Schema.class_variable_set(:@@field_ids, {})
    }

    after(:each) {
      Arnoldb::Schema.class_variable_set(:@@fields, {})
      Arnoldb::Schema.class_variable_set(:@@field_ids, {})
    }

    it "adds a field" do
      allow(Arnoldb::Schema).to receive(:get_title) { "PROFILES" }
      Arnoldb::Schema.add_column("first", "123","456")

      expect(Arnoldb::Schema.class_variable_get(:@@fields)).to include("PROFILES.first" => "123")
      expect(Arnoldb::Schema.class_variable_get(:@@field_ids)).to include("123" => "PROFILES.first")
    end

    it "normalizes titles" do
      allow(Arnoldb::Schema).to receive(:get_title) { "PROFILES" }
      Arnoldb::Schema.add_column("laSt_namE", "789","456")
      Arnoldb::Schema.add_column("STYLE", "101112","456")
      Arnoldb::Schema.add_column("g FACTOR", "131415","456")

      expect(Arnoldb::Schema.class_variable_get(:@@fields)).to include("PROFILES.last_name" => "789")
      expect(Arnoldb::Schema.class_variable_get(:@@field_ids)).to include("789" => "PROFILES.last_name")
      expect(Arnoldb::Schema.class_variable_get(:@@fields)).to include("PROFILES.style" => "101112")
      expect(Arnoldb::Schema.class_variable_get(:@@field_ids)).to include("101112" => "PROFILES.style")
      expect(Arnoldb::Schema.class_variable_get(:@@fields)).to include("PROFILES.g factor" => "131415")
      expect(Arnoldb::Schema.class_variable_get(:@@field_ids)).to include("131415" => "PROFILES.g factor")
    end
  end
end
