require 'pry'
class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: id = nil, name: name, breed: breed)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
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

    def self.create(name:, breed:)
        dog = Dog.new(name, breed)
        dog.save
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL
        query = DB[:conn].execute(sql, id)[0]
        Dog.new(query[0], query[1], query[2])
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL
        query = DB[:conn].execute(sql, name)[0]
        dog = Dog.new(query[0], query[1], query[2])
        dog
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
            INSERT INTO dogs(name, breed)
            VALUES (?, ?)
            SQL
            query = DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            #dog = Dog.new(query[0], query[1], query[2])
        end
        self
    end

    def update
        sql = 'UPDATE dogs SET name = ?, breed = ? WHERE id = ?'
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end 