# Arnoldb

This gem provides a way to easily map the functionality of an Arnoldb database to
a ruby project. The core concepts behind this gem's structure and functionality 
are derived from the popular
[ActiveRecord](https://github.com/rails/rails/tree/master/activerecord) gem.

## Features

### Map Arnoldb Object Types easily through Inheritance

```ruby
class Library < Arnoldb::Mapper; end
```

Create setter and getters for each Arnoldb field.

### Set up associations

```ruby
class Library < Arnoldb::Mapper
  has_many :book
  belongs_to :city
end
```

Creates associations based off common syntax.

### Query for historic objects

```ruby
user = User.new
user.name = "Arnold"
user.id = "12345-a"
user.save # creates a new record in Arnoldb for the current time

User.find("12345-a") # retrieves record from Arnoldb
user.name = "Terminator"
user.effective_date = 467611200 # unix time
user.save # creates a new record in Arnoldb for a date in the past

user = User.find("12345-a", 467611200) # second parameter is the desired query date
user.name # -> "Terminator"
```

Enable historic Queries on objects.

### Build migrations to help manage Arnoldb updates

```ruby
class CreateUsers < Arnoldb::Migration
  def up
    create_table "users" do |t|
      t.string "id"
      t.string "name"
    end
  end
end
```

Add the ability to run migrations and also keeps track of ran migrations.

### Rebuild Arnoldb states from tracked Schema

```ruby
Arnoldb::Schema.define do
  add_table "users" do |t|
    t.string "id"
    t.string "name"
  end
end
```

The schema.rb file enables developers to quickly visualize Arnoldb's database as
a standard relational database and gives them the power to reconstruct an Arnoldb
database state.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'arnoldb'
```

And then execute:

    $ bundle

Or install it yourself with:

    $ gem install arnoldb

## POC

- Jim Walker jim.walker@namely.com

## License

The Arnoldb gem is under the [MIT license](LICENSE).
