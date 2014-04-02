require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name.to_s.singularize}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name  = options[:class_name]  || name.to_s.singularize.camelcase
  end
  
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || 
                      "#{self_class_name.to_s.underscore}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name  = options[:class_name]  || name.to_s.singularize.camelcase
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    define_method(name) do
      options.model_class.where(
        options.primary_key => self.send(options.foreign_key)
        )
        .first
    end
    assoc_options[name] = options
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    define_method(name) do
      options.model_class.where(
        options.foreign_key => self.send(options.primary_key)
        )
    end
  end

  def assoc_options
    @associations ||= Hash.new
  end
  
  def self.has_one_string(through_options, source_options)
    through_table = through_options.model_class.table_name
    source_table = source_options.model_class.table_name
    
    <<-SQL
       SELECT
         #{source_table}.*
       FROM
         #{through_table}
       JOIN
         #{source_table}
       ON
         #{through_table}.#{source_options.foreign_key}
         =
         #{source_table}.#{source_options.primary_key}
       WHERE
         #{through_table}.#{through_options.primary_key}
         = 
         ?
    SQL
  end
  
  def has_one_through(name, through_name, source_name)
     define_method(name) do
       through_options = self.class.assoc_options[through_name]
       source_options = through_options.model_class.assoc_options[source_name]
       
       query = Associatable.has_one_string(through_options, source_options)
       query_column = self.send(through_options.foreign_key)
       
       results = DBConnection.execute(query, query_column)                        
       source_options.model_class.new(results.first)
    end
  end
  
end

class SQLObject
  extend Associatable
end
