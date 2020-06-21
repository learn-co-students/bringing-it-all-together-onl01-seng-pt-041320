require "pry"
class Dog
    attr_accessor :id, :name, :breed
    
    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end
    
    def save
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
        
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        
        self
    end
    
    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create_table
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
        sql = "DROP TABLE dogs"

        DB[:conn].execute(sql)
    end

    def self.create(name:, breed:)
        new_dog = self.new(name: name, breed: breed)

        new_dog.save
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        #binding.pry

        self.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id_num)
        sql = "SELECT * FROM dogs WHERE id = ?"

        dog = DB[:conn].execute(sql, id_num)
        #binding.pry

        id = dog[0][0]
        name = dog[0][1]
        breed = dog[0][2]

        self.new(id: id, name: name, breed: breed)
    end

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
        dog = DB[:conn].execute(sql, name, breed)
        #binding.pry

        if dog.empty?
            dog = self.create(name: name, breed: breed)
        else
            id = dog[0][0]
            name = dog[0][1]
            breed = dog[0][2]

            self.new(id: id, name: name, breed: breed)
        end
        #binding.pry
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        dog = DB[:conn].execute(sql, name)

        id = dog[0][0]
        name = dog[0][1]
        breed = dog[0][2]

        self.new(id: id, name: name, breed: breed)
    end
end