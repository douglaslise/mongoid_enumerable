# Mongoid Enumerable

[![Build Status](https://travis-ci.org/douglaslise/mongoid_enumerable.svg?branch=master)](https://travis-ci.org/douglaslise/mongoid_enumerable)
[![Maintainability](https://api.codeclimate.com/v1/badges/bc09bc91c31fed14924a/maintainability)](https://codeclimate.com/github/douglaslise/mongoid_enumerable/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/bc09bc91c31fed14924a/test_coverage)](https://codeclimate.com/github/douglaslise/mongoid_enumerable/test_coverage)
[![Gem Version](https://badge.fury.io/rb/mongoid_enumerable.svg)](https://badge.fury.io/rb/mongoid_enumerable)

Define enumerable fields in your Mongoid documents.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mongoid_enumerable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongoid_enumerable

## Usage
Simply include `MongoidEnumerable` in your document.
After add `enumerable` with:
 - Field name
 - An array with possible values
 - Options (`default` and/or `prefix`)

Example:

```ruby
class Task
  include Mongoid::Document
  include MongoidEnumerable

  enumerable :status, %w(completed running failed waiting), default: "waiting"
end
```

Now we have methods in this document's instance:
```ruby
task = Task.new

task.status   # "waiting"
task.waiting? # true

task.running! # changes status field to "running"
task.running? # true
task.waiting? # false
```

### Options
#### Default
Defines which value is the default for new documents. If not specified the first value is used as default.
```ruby
enumerable :status, %w(completed running failed waiting), default: "waiting"
```
#### Prefix
You can define a prefix for your methods that could be useful if you have more than one enumerable with the same values.
```ruby
enumerable :build_status, %w(completed running failed waiting), default: "waiting", prefix: "build_"
enumerable :deploy_status, %w(completed running failed waiting), default: "waiting", prefix: "deploy_"

task.build_completed?
task.build_failed!
task.deploy_running?
task.deploy_failed!
```


### Scopes/Criterias
All values are added as scopes/criterias to your document class:
```ruby
Task.waiting # Returns all tasks with waiting status
Task.running # Returns all tasks with running status
```

If prefixed, the scopes/criterias are prefixed too:
```ruby
Task.build_waiting # Returns all tasks with build waiting status
Task.deploy_running # Returns all tasks with deploy running status
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/douglaslise/mongoid_enumerable.
