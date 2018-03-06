require "pry"
class Dog


  attr_accessor :name, :breed, :id, :color, :instagram

  def initialize(dog_attributes)
    @id = dog_attributes[:id]
    @name = dog_attributes[:name]
    @breed = dog_attributes[:breed]
    @color = dog_attributes[:color]
    @instagram = dog_attributes[:instagram]
  end


def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
       INSERT INTO dogs(name, breed) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    if !@id
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
    # binding.pry
  end

  def self.create(dog_attributes)
    dog = Dog.new(dog_attributes)
    dog.save
    # binding.pry
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"

    row = DB[:conn].execute(sql, id)[0]
    dog_attributes = {id: row[0], name: row[1], breed: row[2]}
    d = Dog.create(dog_attributes)
    # binding.pry
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)[0]
    # binding.pry
    if dog
      dog_attributes = {id: dog[0], name: dog[1], breed: dog[2]}
      dog = Dog.new(dog_attributes)
    else
      dog_attributes = {name: name, breed: breed}
      dog = self.create(name: name, breed: breed)
    end
    dog
    # binding.pry
  end

  def self.new_from_db(row)
    dog_attributes = {id: row[0], name: row[1], breed: row[2]}
    dog = Dog.new(dog_attributes)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    dog = DB[:conn].execute(sql, name)[0]
    self.new_from_db(dog)
    # binding.pry
  end

  def update
    sql = "UPDATE dogs SET name = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.id)
  end

end
