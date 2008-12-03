# A common interface for the different rates.
class RateRequest
  # There's a list of country codes in config/country_codes.yml generated
  # directly from the ISO website (http://www.iso.org/iso/list-en1-semic-2.txt)
  # 
  # You can re-generate that list with the update_country_codes rake task
  COUNTRY_CODES = YAML.load(
    File.read(
      File.dirname(__FILE__) + "/../../config/country_codes.yml"
    )
  ).invert

  # We give each carrier, code, and service a unique id in config/service_ids.yml
  # to make it easier to deal with.
  # 
  # See the generate_service_ids rake task for more info on creating the yaml
  SERVICE_IDS = YAML.load(
    File.read(
      File.dirname(__FILE__) + "/../../config/service_ids.yml"
    )
  )

  ##
  # Gets all Rates from all carriers for the given options
  # === Options
  # Most options will be passed right in to the specific carrier rate reqest.
  # If it's not listed here but it is in the carrier rate request, putting
  # it here will send it to both. Might work, or might make conflicts.
  # [+:zip+]     Destination zip. Required for US shipments.
  # [+:weight+]  Weight in pounds. Always Required.
  # [+:country+] Two-digit country code (ex "US"). Always Required.
  def self.get_multiple(options = {}, use_internal_ids = false)
    ups_rates = UPSRateRequest.new(options).do
    usps_rates = USPSRateRequest.new(options).do
    rates = usps_rates + ups_rates
    
    rates = add_id_to_rates(rates) if use_internal_ids
      
    return rates
  end
  
  # Returns a single Rate for a given carrier and code
  def self.get(carrier, code, options = {})
    "#{carrier}RateRequest".constantize.new({:service => code}.merge(options)).do
  end

  def self.get_by_method_id(method_id, options = {})
    method = self.method_from_id(method_id)
    self.get(method[:carrier], method[:code], options)
  end
  
  # === Parameters
  # [+id+] An Integer identifying the unique carrier, code, and service
  # === Returns
  # hash of the form
  # {:carrier => 'Carrier', :code => 'code', :service => 'service'}
  # 
  # (nil if not found)
  def self.method_from_id(id)
    SERVICE_IDS[id.to_i]
  end
  
  # === Parameters
  # [+method_hash+] hash of the form
  #                 {:carrier => 'Carrier', :code => 'code', :service => 'service'}
  # === Returns
  # An Integer identifying the unique carrier, code, and service
  def self.id_from_method(method_hash)
    method = SERVICE_IDS.find do |key, value|
      method_hash[:service].downcase == value[:service].downcase &&
      method_hash[:code] == value[:code] &&
      method_hash[:carrier] == value[:carrier] &&
      method_hash[:context] == value[:context]
    end
    return method ? method[0] : nil
  end

  def self.add_id_to_rates(rates)
    rates.each {|rate| rate.set_method_id }
  end
end











