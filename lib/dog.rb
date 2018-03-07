require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(attributes)
    @id
    attributes.map {|key, value| self.send(("#{key}="), value)}
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
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if !self.id
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    else
      self.update
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT id, name, breed FROM dogs WHERE id = ?
    SQL
    attributes = DB[:conn].execute(sql, id)[0]
    self.new_from_db(attributes)
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT id, name, breed FROM dogs WHERE name = ? AND breed = ?
    SQL
    attributes = DB[:conn].execute(sql,hash[:name],hash[:breed])[0]
    if !attributes
      dog = self.new(hash)
      dog.save
      dog
    else
      dogattr = {:name=>attributes[1],:breed=>attributes[2]}
      dog = self.new(dogattr)
      dog.id=attributes[0]
      dog
    end
  end

  def self.new_from_db(attributes)
    hash = {:id=>attributes[0],:name=>attributes[1],:breed=>attributes[2]}
    self.new(hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT id, name, breed FROM dogs WHERE name = ?
    SQL
    attributes = DB[:conn].execute(sql,name)[0]
    self.new_from_db(attributes)
  end

end
