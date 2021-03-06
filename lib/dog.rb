class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs;"
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?);
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(attributes)
        new_dog = Dog.new(id: attributes[:id], name: attributes[:name], breed: attributes[:breed])
        new_dog.save
    end

    def self.new_from_db(dog_row_array)
        new_id = dog_row_array[0]
        new_name = dog_row_array[1]
        new_breed = dog_row_array[2]
        new_dog = Dog.new(id: new_id, name: new_name, breed: new_breed)
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?;
        SQL
        dog = DB[:conn].execute(sql, id).first
        self.new_from_db(dog)
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
          dog_data = dog[0]

          dog= Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end 

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?;
        SQL
        dog = DB[:conn].execute(sql, name).first
        Dog.new_from_db(dog)
    end

    
    def update
        sql = <<-SQL
            UPDATE dogs SET 
            name = ?, 
            breed = ?
            WHERE id = ?;
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end