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

  ##
  # Gets all Rates from all carriers for the given options
  # === Options
  # Most options will be passed right in to the specific carrier rate reqest.
  # If it's not listed here but it is in the carrier rate request, putting
  # it here will send it to both. Might work, or might make conflicts.
  # [+:zip+]     Destination zip. Required for US shipments.
  # [+:weight+]  Weight in pounds. Always Required.
  # [+:country+] Two-digit country code (ex "US"). Always Required.
  def self.get_multiple(options = {})
    ups_rates = UPSRateRequest.new(ups_options(options)).do
    usps_rates = USPSRateRequest.new(usps_options(options)).do
    return usps_rates + ups_rates
  end
  
  # Returns a single Rate for a given carrier and code
  def self.get(carrier, code, options = {})
    "#{carrier}RateRequest".constantize.new({:service => code}.merge(options)).do
  end
  
private

  def self.usps_options(options)
    opts = options.dup
    
    return opts
  end
  
  def self.ups_options(options)
    opts = options.dup
    
    return opts
  end
end
