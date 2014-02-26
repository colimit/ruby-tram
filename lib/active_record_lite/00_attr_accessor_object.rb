class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |meth_name|
      attr_name = "@#{meth_name}"
      define_method(meth_name) do
        instance_variable_get(attr_name)
      end
      define_method("#{meth_name}=") do |other|
        instance_variable_set(attr_name, other)
      end
    end
  end
end
