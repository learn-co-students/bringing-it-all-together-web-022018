require_relative '../config/environment'
require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = hash[:id]
  end


  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)

  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    SQL

    DB[:conn].results_as_hash = true
    dogs_hash = DB[:conn].execute(sql, id)[0]
    dogs = Dog.new({:name => dogs_hash["name"], :breed => dogs_hash["breed"], :id => dogs_hash["id"]})

  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ? AND breed = ?
    SQL

    DB[:conn].results_as_hash = true
    row = DB[:conn].execute(sql, name, breed)[0]

    if row == nil
      self.create(name: name, breed: breed)
    else
      self.new({:name => row["name"], :breed => row["breed"], :id => row["id"]})
    end

  end

  def self.new_from_db(row)
    student = Dog.new({:name => row[1], :breed => row[2], :id => row[0]})
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    SQL

    DB[:conn].results_as_hash = true
    dogs_hash = DB[:conn].execute(sql, name)[0]
    dogs = Dog.new({:name => dogs_hash["name"], :breed => dogs_hash["breed"], :id => dogs_hash["id"]})

  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, name, breed, id)
  end

end
