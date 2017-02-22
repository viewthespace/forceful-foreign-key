# ForcefulForeignKey

When `force: true` is set, It will delete orphaned data before applying the foreign key constraint. Use cautiously!

```Ruby
class AddFKContraint < ActiveRecord::Migration
  def change
    add_foreign_key 'foo', 'bar', force: true
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'forceful_foreign_key'
```
tall forceful_foreign_key

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
