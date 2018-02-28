class Dog
  attr_reader :id
  attr_accessor :name,:breed

  # The #initialize method accepts a hash or keyword argument value with key-value pairs as an argument.
  # key-value pairs need to contain id, name, and breed.
  def initialize(attrib)
    @id=attrib[:id]
    @name=attrib[:name]
    @breed=attrib[:breed]
  end #initialize

  def save
    DB[:conn].execute("INSERT INTO dogs(name,breed) VALUES (? , ?)", @name,@breed) if @id.nil?
    @id = DB[:conn].execute("SELECT last_insert_rowid() from dogs")[0][0]
    self
  end

  def update
    DB[:conn].execute("UPDATE dogs set name = ? where id = ?",@name,@id)
    DB[:conn].execute("UPDATE dogs set breed = ? where id = ?",@breed,@id)
  end

  def self.create(attrib)
    dog=self.new(attrib)
    dog.save
  end
  # ::create_table Your task here is to define a class method on Dog that will execute the correct SQL
  # to create a dogs table.
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end #create_table

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("select * from dogs where id = ?",id)[0]
    attrib = { id: row[0], name: row[1], breed: row[2] }
    self.new(attrib)
  end

  def self.find_by_name(name)
    # puts "#{name}"
    row = DB[:conn].execute("select * from dogs where name = ?",name)[0]
    # puts "#{row}"
    attrib = { id: row[0], name: row[1], breed: row[2] }
    self.new(attrib) if !row.nil?
  end

  def self.find_or_create_by(attrib) #{:name=>"teddy", :breed=>"cockapoo"}
    # puts "#{attrib}"
    row = DB[:conn].execute("select * from dogs where name = ? and breed = ?", attrib[:name], attrib[:breed])[0]
    row.nil? ? self.create(attrib) : self.find_by_id(row[0])
  end

  def self.new_from_db(row)
    attrib = {id: row[0], name: row[1], breed: row[2]}
    self.new(attrib)
  end


end #class
