# Arnoldb

This gem provides a way to easily map the functionality of an Arnoldb database to
a ruby project.

## Usage

```ruby
connection = Arnoldb.connect("localhost:2222")
Arnoldb::Base.new(connection)
```

### Endpoints

For available endpoints view the [documentation](http://www.rubydoc.info/github/namely/arnoldb-ruby/master).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'arnoldb'
```

And then execute:

    $ bundle

Or install it yourself with:

    $ gem install arnoldb

## Running Tests

Make sure that docker, docker-machine, docker-compose, and some virtual machine
software is installed.

```bash
docker-machine create arnoldb-gem -d virtualbox
eval $(docker-machine env arnoldb-gem)
docker-compose up
```

## POC

- Jim Walker jim.walker@namely.com

## License

The Arnoldb gem is under the [MIT license](LICENSE).
