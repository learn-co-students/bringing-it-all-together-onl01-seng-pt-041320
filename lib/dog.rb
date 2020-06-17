require 'pry'

class Dog

    attr_accessor :name, :breed, :id

    def initialize(attr)
        attr.each do |key, value| 
            self.send(("#{key}="), value)
        end
        self.id ||= nil
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

    # saves into DB
    def save 
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self # returns instance of dog
    end

    def self.create(attr)
        dog = self.new(attr)
        dog.save
        dog
    end

    def self.new_from_db(row)
        attributes = {
            :id => row[0],
            :name => row[1],
            :breed => row[2]
        }
        dog = self.new(attributes)
    end

    def self.find_by_id(index)
        sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE id = ?
        SQL
        DB[:conn].execute(sql, index).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs where name = ? AND breed = ?", name, breed).first
        # why does .first return nil when dog is evaluated, while without .first dog evals to []?
        if dog
            new_dog = self.new_from_db(dog)
        else
            new_dog = self.create({:name => name, :breed => breed})
        end
        new_dog
        # binding.pry
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE name = ?
        SQL
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end 

    def update
        sql = <<-SQL
        UPDATE dogs 
        SET name = ?
        WHERE ID = ?
        SQL
        DB[:conn].execute(sql, self.name, self.id)
    end

end