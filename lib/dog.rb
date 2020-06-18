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
        SQL
    end
end