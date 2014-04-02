require_relative 'db_connection'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map do |params|
      self.new(params)
    end
  end
end

class SQLObject < MassObject
  def self.columns
    @columns ||= begin
      DBConnection.instance
        .execute2("SELECT * FROM #{table_name}")
        .first
        .map(&:to_sym)
        .tap { |cols| hash_attr_accessor(*cols)  }
    end
  end

  #makes accessor methods for fields in the attributes hash
  def self.hash_attr_accessor(*names)
    names.each do |meth_name|
      define_method(meth_name) do
        attributes[meth_name.to_sym]
      end
      define_method("#{meth_name}=") do |other|
        attributes[meth_name.to_sym] = other
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= name.underscore.pluralize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    SQL
    puts results
    parse_all(results)
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id.to_i).first
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    WHERE
      id = ?
    SQL
    puts result
    self.new(result)
  end

  def attributes
    @attributes ||= Hash.new
  end

  def insert
    columns_string = self.class.columns.map(&:to_s).join(", ")
    question_marks = self.class.columns.map { "?" }.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
         #{self.class.table_name} (#{columns_string})
      VALUES
         (#{question_marks})
      SQL
    self.id = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      if self.class.columns.include?(attr_name.to_sym)
        send("#{attr_name}=", value)
      else
        raise "parameter not a column in #{table_name}"
      end
    end
  end

  def save
    self.id ? update : insert
  end

  def update
    non_id_cols = self.class.columns[1..-1]
    setter_string = non_id_cols.map { |col| "#{col} = ?"}.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values[1..-1])
      UPDATE
         #{self.class.table_name}
      SET
         #{setter_string}
      WHERE
        id = #{self.id}
    SQL
  end

  def attribute_values
    self.class.columns.map { |col_name| send(col_name) }
  end

end
