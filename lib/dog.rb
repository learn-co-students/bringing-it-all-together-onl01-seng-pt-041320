require 'pry'

class Dog
    attr_accessor :name, :breed, :id
  
    def initialize(name:, breed:, id:nil)
      @id = id
      @name = name
      @breed = breed
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
      sql = "DROP TABLE IF EXISTS dogs"
      DB[:conn].execute(sql)
    end
  
    def save
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end
  
    def self.create(name:, breed:)
      dog = Dog.new(name:name, breed:breed)
      dog.save
      dog
    end
  
    def self.new_from_db(row)
        Dog.new(id:row[0], name:row[1], breed:row[2])
    end

    def self.find_by_id(id)
        sql = 'SELECT * FROM dogs WHERE id = ?'
        result = DB[:conn].execute(sql, id)[0]
        Dog.new(id:result[0], name:result[1], breed:result[2])
    end
  
    def self.find_by_name(name)
      sql = "SELECT * FROM dogs WHERE name = ?"
      result = DB[:conn].execute(sql, name)[0]
      Dog.new(id:result[0], name:result[1], breed:result[2])
    end

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
        result = DB[:conn].execute(sql, name, breed)[0]
        if !result
            self.create(name:name, breed:breed)
        else
            self.find_by_id(result[0])
        end
    end
  
    def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
  
  
  end