require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params = parse_www_encoded_form(req.query_string || "")
    @params.deep_merge!(parse_www_encoded_form(req.body || ""))
    @params.deep_merge!(route_params)
    @permitted_keys = []
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    @permitted_keys.concat(keys)
  end

  def require(key)
    raise AttributeNotFoundError unless @params.has_key?(key)
  end

  def permitted?(key)
    @permitted_keys.include?(key)
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private

  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    pairs = URI.decode_www_form(www_encoded_form)
    rec_hash.tap do |result|
      pairs.each { |key, value| set_hash_key(result, parse_key(key), value) }
      deep_set_nil_default(result)
    end
  end

  #resets all defaults in a nested hash to nil
  def deep_set_nil_default(hash)
    return unless hash.is_a?(Hash)
    hash.default = nil
    hash.each_value { |value| deep_set_nil_default(value) }
  end

  #Example: if key_list = ["foo","bar", "baz"],
  #set_hash_key(hash, key_list, value) sets
  #hash["foo"]["bar"]["baz"] = value
  def set_hash_key(hash, key_list, value)
    return (hash[key_list[0]] = value) if key_list.length == 1
    set_hash_key(hash[key_list[0]], key_list[1..-1], value)
  end

  #defines up a hash, who's default is a hash, with default a hash, ad infinitum
  def rec_hash
    Hash.new { |h, k| h[k] = rec_hash }
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end

  #merges nested hash2 into hash1 in place, with overwriting
  def deep_merge!(hash1, hash2)
    hash2.each do |key, value|
      hash1[key] = value unless value.is_a?(Hash) && hash1[key].is_a?(Hash)
      deep_merge!(hash1[key], hash2[key])
    end
  end
end
