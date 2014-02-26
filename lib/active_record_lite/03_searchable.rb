require_relative 'db_connection'
require_relative '02_sql_object'
require_relative 'relation.rb'

module Searchable
  def where(params)
    Relation.new(self).where(params)
    
    # params_array = params.each.to_a    #for order safety, maybe I'm paranoid
    # where_string = params_array.map {|attr, _| "#{attr} = ?" }.join(" AND ")
    # values = params_array.map {|_, value| value}
    # results = DBConnection.execute(<<-SQL, *values)
    #   SELECT 
    #     *
    #   FROM
    #     #{table_name}
    #   WHERE
    #     #{where_string}
    # SQL
    # self.parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
