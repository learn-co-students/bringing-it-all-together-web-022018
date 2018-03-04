class Dog
  attr_accessor :name, :breed
  attr_reader :id
  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    self.drop_table
    sql = <<-SQL
      CREATE TABLE dogs (
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
      if self.id
        self.update
      else
        insert = <<-SQL
          INSERT INTO dogs (name, breed) VALUES (?,?)
          SQL
          DB[:conn].execute(insert, self.name, self.breed)
          resp = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0]
          @id = resp[0]
        end
        self
      end
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end
  def update
    updating = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
      SQL
      DB[:conn].execute(updating, self.name,
      self.breed, self.id)
    end
  def self.find_or_create_by(name:, breed:)
     dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")
     if !dog.empty?
       new_dog = Dog.new(id: dog[0][0], name: dog[0][1], breed: dog[0][2])
     else
       new_dog = self.create(name: name, breed: breed)
     end
     new_dog
   end
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
      SQL
      DB[:conn].execute(sql,name).map do |row|
        self.new_from_db(row)
      end.first
    end
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
      SQL
      DB[:conn].execute(sql, id).map do |row|
        self.new_from_db(row)
      end.first
    end
  end
