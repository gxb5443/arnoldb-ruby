# Arnoldb

This gem provides a way to easily map the functionality of an Arnoldb database to
a ruby project. The core concepts behind this gem's structure and functionality 
are derived from the popular
[ActiveRecord](https://github.com/rails/rails/tree/master/activerecord) gem.


## Usage

```

connection = Arnoldb.connect("localhost:2222")

Arnoldb::Interface.new(connection)

```


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
