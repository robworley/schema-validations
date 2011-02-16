require 'test/unit'

require 'rubygems'
require 'active_record'

require File.join(File.dirname(__FILE__), '..', 'lib', 'schema_validations')

ActiveRecord::Base.establish_connection({
  'database' => ':memory:',
  'adapter' => 'sqlite3',
  'timeout' => 500
})

ActiveRecord::Schema.define do
  create_table "users", :force => true do |t|
    t.string  :name, :null => false, :limit => 20
    t.integer :age
    t.string  :crypted_password, :null => false
    t.boolean :active, :null => false, :default => true
  end
end

class User < ActiveRecord::Base
  include SchemaValidations
  skip_schema_validations :crypted_password
end

class SchemaValidationsTest < Test::Unit::TestCase
  def test_valid_records_pass
    user = User.new(:name => 'Adrian', :age => 13)
    assert user.valid?
  end

  def test_validates_not_null_fields
    user = User.new(:name => nil)
    assert !user.valid?
    assert_equal "can't be blank", user.errors.on(:name)
  end

  def test_validates_string_lengths
    user = User.new(:name => 'Stuckkeyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy')
    assert !user.valid?
    assert_equal "is too long (maximum is 20 characters)", user.errors.on(:name)
  end

  def test_validates_numbers
    user = User.new(:name => 'Adrian', :age => 'thirteen and a bit')
    assert !user.valid?
    assert_equal "is not a number", user.errors.on(:age)
  end

  def test_validates_integers
    user = User.new(:name => 'Adrian', :age => 13.75)
    assert !user.valid?
    assert_equal "is not a number", user.errors.on(:age)
  end

  def test_validates_booleans
    user = User.new(:active => nil)
    assert !user.valid?
    assert_equal "can't be blank", user.errors.on(:active)
  end

  def test_skips_validation_when_instructed
    user = User.new(:name => 'Adrian')
    user.valid?
    assert_nil user.errors.on(:first_name)
  end
end
