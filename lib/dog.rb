class Dog 
	attr_accessor :name, :breed
	attr_reader :id

	def initialize(name:, breed:, id:nil)
		@name = name
		@breed = breed
		@id = id
	end

	def self.create_table
		sql = <<-SQL
			create table if not exists dogs(
				id integer primary key,
				name text,
				breed text
			)
		SQL

		DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = <<-SQL
			drop table if exists dogs
		SQL

		DB[:conn].execute(sql)
	end


	def self.new_from_db(row)
		dog = Dog.new({name:row[1], breed:row[2], id:row[0]})
		dog
	end

	def self.find_by_id(id)
		sql = <<-SQL
			select * from dogs
			where id = ?
		SQL

		self.new_from_db(DB[:conn].execute(sql, id)[0])
	end

	def self.find_by_name(name)
		sql = <<-SQL
			select * from dogs
			where name = ?
		SQL

		self.new_from_db(DB[:conn].execute(sql, name)[0])
	end

	def update
		sql = <<-SQL
			update dogs
			set name = ?, breed = ?
			where id = ?
		SQL

		DB[:conn].execute(sql, @name, @breed, @id)
	end

	def self.create(hash)
		dog = Dog.new(hash)
		dog.save
	end

	def save
		if @id
			update
		else
			sql = <<-SQL
				insert into dogs
				(name, breed)
				values (?, ?)
			SQL

			DB[:conn].execute(sql, @name, @breed)

			@id = DB[:conn].execute("select last_insert_rowid() from dogs")[0][0]
		end
		self

	end

	def self.find_or_create_by(name:, breed:)
		sql = <<-SQL
			select * from dogs
			where name = ? and breed = ?
		SQL

		array = DB[:conn].execute(sql, name, breed)

		if !array.empty?
			dog = Dog.new({name:array[0][1], breed:array[0][2], id:array[0][0]})
		else
			dog = Dog.create({name:name, breed:breed})
		end
		dog
	end





end