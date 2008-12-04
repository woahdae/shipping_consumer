class Service
  attr_accessor :name, :code, :carrier, :context, :id

  # See the generate_service_ids rake task for more info on creating the yaml
  SERVICE_IDS = YAML.load(File.read(File.dirname(__FILE__) + 
    "/../../config/service_ids.yml"
  ))
  
  def initialize(attrs = {})
    initialize_attributes attrs
  end
  
  def self.find(id)
    attrs = SERVICE_IDS[id.to_i]
    
    if attrs.nil? || attrs.empty?
      return nil 
    else
      return self.new(attrs)
    end
  end
  
  def self.find_by_attributes(attrs)
    found = SERVICE_IDS.find do |key, value|
      attrs[:code] == value[:code] &&
      attrs[:carrier] == value[:carrier] &&
      attrs[:context] == value[:context]
    end
    
    if found
      service_hash = found[1]
      service_hash[:id] = found[0]
      return self.new(service_hash)
    else
      return nil
    end
  end
  
  def [](attribute)
    self.send(attribute)
  end
  
  def []=(attribute)
    self.send(attribute.to_s + "=", attribute)
  end
  
private
  
  def initialize_attributes(attrs)
    attrs.each do |attr, value|
      self.instance_variable_set("@#{attr}", value)
    end
  end
  
end