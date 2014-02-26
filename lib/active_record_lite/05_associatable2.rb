require_relative '04_associatable'

# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

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
