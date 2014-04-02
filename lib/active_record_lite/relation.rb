class Relation
  include Enumerable
  
  def initialize(base_class)
    @base_class = base_class
    @where_conditions = []
    @where_values = []
    @records = nil
  end
  
  
  #evaluates the where conditions, filling values
  def force
    where_string = "(#{ @where_conditions.join(') AND (') })"
    results = DBConnection.execute(<<-SQL, *@where_values)
          SELECT 
            *
          FROM
            #{@base_class.table_name}
          WHERE
            #{where_string}
        SQL
    @records = @base_class.parse_all(results)
  end
  
  #puts the next where condition into @where_conditions
  def where(condition, *where_values)
    if condition.is_a?(String)
      where_string = condition
    else
      params_array = condition.each.to_a
      where_string = params_array.map {|attr, _| "#{attr} = ?" }.join(" AND ")
      where_values.clear.concat(params_array.map { |_, value| value })
    end
    @records = nil
    @where_values.concat(where_values)
    @where_conditions << where_string
    self
  end 
  
  #asdf
  
  def each(&block)
    force if @records.nil?
    @records.each(&block)
  end
    
  def method_missing(meth, *args, &block)
    # if it's an array method, calls force then send
    if Array.new.methods.include?(meth)
      force if @records.nil?
      @records.send(meth, *args, &block)
    else
      super
    end  
  end
 
  
  
end