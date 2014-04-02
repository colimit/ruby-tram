require_relative 'db_connection'
require_relative 'sql_object'
require_relative 'relation.rb'

module Searchable
  def where(params)
    Relation.new(self).where(params)
  end
end

class SQLObject
  extend Searchable
end
