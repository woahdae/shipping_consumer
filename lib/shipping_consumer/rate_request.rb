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

  def self.get_from_service_id(id, options = {})
    service = Service.find(id)
    self.get(service.carrier, service.code, options)
  end

  # Returns a single Rate for a given carrier and code
  def self.get(carrier, code, shipping_params = {})
    "#{carrier}RateRequest".constantize.do(shipping_params.merge(:code => code)).first
  end

  ##
  # Gets all Rates from all carriers for the given options
  # === Shipping Parameters
  # Most options will be passed right in to the specific carrier rate reqest.
  # If it's not listed here but it is in the carrier rate request, putting
  # it here will send it to both. Might work, or might make conflicts.
  # [+:zip+]     Destination zip. Required for US shipments.
  # [+:weight+]  Weight in pounds. Always Required.
  # [+:country+] Two-digit country code (ex "US"). Always Required.
  def self.get_multiple(shipping_params = {}, use_service_ids = false)
    ups_rates = UPSRateRequest.do(shipping_params) || []
    usps_rates = USPSRateRequest.do(shipping_params) || []
    rates = usps_rates + ups_rates
    
    return rates
  end
  
end











