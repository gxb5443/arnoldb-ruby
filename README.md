![Build
Status](https://circleci.com/gh/namely/arnoldb-ruby/tree/master.png?style=shield&circle-token=6a9569b014658ce403e1a1ab505f04f94aae580f)
[![Inline
docs](http://inch-ci.org/github/namely/arnoldb-ruby.svg)](http://inch-ci.org/github/namely/arnoldb-ruby)

<p align="center">
<img
src="https://raw.githubusercontent.com/namely/arnoldb-ruby/master/static/arnoldb-horizontal.png" alt="ArnolDB Logo" />
</p>
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
