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
    attrs = hash_from_id(id)
    
    return nil if attrs.nil?
    
    return Service.new(attrs)
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
  
  def to_hash
    Service.hash_from_id(self.id)
  end

  # crystalcommerce specific code

  def custom
    false
  end
  
  def service
    self.name
  end
  
  def custom?
    false
  end
  
  # end CC code
  protected

  def self.hash_from_id(id)
    attrs = SERVICE_IDS[id.to_i]
    
    if attrs.nil? || attrs.empty?
      return nil 
    else
      return attrs.merge(:id => id)
    end
  end
  
  private
  
  def initialize_attributes(attrs)
    attrs.each do |attr, value|
      self.instance_variable_set("@#{attr}", value)
    end
  end
  
end