# Mongoid Enumerable

[![Unit Tests](https://github.com/douglaslise/mongoid_enumerable/workflows/Unit%20Tests%20-%20RSpec/badge.svg?branch=master)](https://github.com/douglaslise/mongoid_enumerable/actions?query=workflow%3A%22Unit+Tests+-+RSpec%22+branch%3Amaster)
[![Lint](https://github.com/douglaslise/mongoid_enumerable/workflows/Lint%20-%20Rubocop/badge.svg?branch=master)](https://github.com/douglaslise/mongoid_enumerable/actions?query=workflow%3A%22Lint+-+Rubocop%22+branch%3Amaster)
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

  enumerable :status, %w[completed running failed waiting], default: "waiting"
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
enumerable :status, %w[completed running failed waiting], default: "waiting"
```
#### Prefix
You can define a prefix for your methods that could be useful if you have more than one enumerable with the same values.
```ruby
enumerable :build_status, %w[completed running failed waiting], default: "waiting", prefix: "build_"
enumerable :deploy_status, %w[completed running failed waiting], default: "waiting", prefix: "deploy_"

task.build_completed?
task.build_failed!
task.deploy_running?
task.deploy_failed!
```
#### Callbacks
##### Before Change
You can define a `before_change` callback that runs before each change. If the method returns a falsey value (`nil` or `false`) then the change is be aborted.

The method must receive two parameters: the old and the new value, respectively.

Example:
```ruby
class Task
  include Mongoid::Document
  include MongoidEnumerable

  enumerable :status, %w[completed running failed waiting], default: "waiting", before_change: :can_status_change?

  def can_status_change?(old_value, new_value)
    new_value != "waiting"
  end
end

task = Task.new
task.status # "waiting"

task.running!
task.status # "running"

task.waiting!
task.status # "running"
```

##### After Change
You can define an `after_change` callback that runs after each change. The method must receive two parameters: the old and the new value, respectively.

Example:
```ruby
class Task
  include Mongoid::Document
  include MongoidEnumerable

  enumerable :status, %w[completed running failed waiting],
    default: "waiting",
    after_change: :status_changed

  def status_changed(old_value, new_value)
    puts "Status changed from #{old_value} to #{new_value}."
  end
end

task = Task.new
task.running!
# Console output: "Status changed from waiting to running."
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

## Releasing a New Version
After change version in file `lib/mongoid_enumerable/version.rb` it is needed only to run this command in terminal:

```shell
rake release
```
