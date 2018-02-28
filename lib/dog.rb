class Dog
  attr_accessor :name, :breed
  attr_reader :id

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

  def self.new_from_db(row)
    self.new({name: row[1], breed: row[2], id: row[0]})
  end

  def save
    if !self.id
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?);
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      sql = <<-SQL
        SELECT id
        FROM dogs
        ORDER BY id
        DESC
        LIMIT 1
      SQL

      @id = DB[:conn].execute(sql)[0][0]
    else
      self.update
    end
    self
  end

  def self.create(hash)
    self.new({name: hash[:name], breed: hash[:breed]}).save
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    self.new_from_db(DB[:conn].execute(sql, name).flatten)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
    self.new_from_db(DB[:conn].execute(sql, id).flatten)
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL

    song = DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten

    if !song.empty?
      out = self.new_from_db(song)
    else
      out = self.create(hash)
    end
  end
  
end
