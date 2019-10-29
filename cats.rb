require 'sqlite3'

DB = {:conn => SQLite3::Database.new("cats.db")}

class Cat
  attr_accessor :name, :breed
  attr_reader :id
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS cats (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def self.table_name
    self.to_s.downcase + "s"
  end
  
  def self.column_names
    sql = <<-SQL
    PRAGMA table._info(#{self.table_name)
    SQL
  end
  
  def initialize(id=nil, name, breed)
    @id = id
    @name = name
    @breed = breed
  end
  
  def save
    values = Cat.column_names.map do |value|
      self.send(value.to_sym)
    end
    question_marks = Cat.column_names.map do |value|
      "?"
    end
    sql = "INSERT INTO #{Cat.table_name} (#{Cat.column_names.join(",")}) VALUES (#{question_marks.join(",")})"
    
    DB[:conn].execute(sql, values)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{Cat.table_name}")[0][0]
    self
  end
  
  def self.find(id)
    sql = <<-SQL
      SELECT * FROM cats WHERE id = ? LIMIT 1
    SQL
    row = DB[:conn].execute(sql, id).first
    Cat.new(row[0], row[1], row[2])
  end
end
Cat.create_table
cat = Cat.new("simba", "tabby").save
cat_from_db = Cat.find(cat.id)
puts cat_from_db.name