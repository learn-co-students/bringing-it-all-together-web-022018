require_relative "../config/environment.rb"
require 'pry'
DB = {:conn => SQLite3::Database.new("db/dogs.db")}

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  hash = {id: nil, name: nil, breed: nil}

  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = hash[:id]
  end

  def self.create_table
    drop_table = <<-SQL
          DROP TABLE IF EXISTS dogs
        SQL
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL
    DB[:conn].execute(drop_table)
    DB[:conn].execute(sql)
  end

  def self.drop_table
    drop_table = <<-SQL
          DROP TABLE IF EXISTS dogs
        SQL
    DB[:conn].execute(drop_table)
  end

  def self.new_from_db(array)
    new_dog_hash = {id: array[0], name: array[1], breed: array[2]}
    new_dog = Dog.new(new_dog_hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
      SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new(id: row[0], name: row[1], breed: row[2])
    end.first
  end

  def save
    id = <<-SQL
      SELECT MAX(id) FROM dogs
        SQL
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute(id)[0][0]
    self
  end

  def self.create(hash)
    new_dog = self.new(hash)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ? LIMIT 1
      SQL
    DB[:conn].execute(sql, id).map do |row|
      self.new(id: row[0], name: row[1], breed: row[2])
    end.first
  end

  def self.find_or_create_by(hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new({id: dog_data[0], name: dog_data[1], breed: dog_data[2]})
    else
      dog = self.create(hash)
    end
    dog
  end


  def update
    updated_dog = Dog.find_by_id(self.id)
    sql = <<-SQL
      UPDATE dogs SET id = ?, name = ?, breed = ? WHERE id = ?
      SQL

    DB[:conn].execute(sql, self.id, self.name, self.breed, self.id)
  end

end
