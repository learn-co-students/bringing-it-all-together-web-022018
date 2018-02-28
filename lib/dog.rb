require "pry"

class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(hash)
    @id = hash[:id]
    @name = hash[:name]
    @breed = hash[:breed]
  end

  def self.create_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    sql = <<-SQL
      CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      self.update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", name, breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
      self
    end
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    arr = DB[:conn].execute(sql, id)[0]
    hash = {id: arr[0], name: arr[1], breed: arr[2]}
    self.new(hash)
  end

  def self.find_or_create_by(hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
    if !dog.empty?
      dog = Dog.new_from_db(dog[0])
    else
      dog = Dog.create(hash)
    end
    dog
  end

  def self.new_from_db(arr)
    dog = Dog.new({id: arr[0], name: arr[1], breed: arr[2]})
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    Dog.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, name, breed, id)
  end

end
