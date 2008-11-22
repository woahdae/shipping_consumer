class Rate
  include Consumer::Mapping
  attr_accessor :service, :code, :price, :carrier, :id
  
  # UPS
  map(:all, "//RatingServiceSelectionResponse/RatedShipment", {
    :price => "TotalCharges/MonetaryValue",
    # :service => "Service",
    :code => "Service/Code"
  }) do |instance, node|
    instance.carrier = "UPS"
    
    country_info = node.find_first("//RatingServiceSelectionResponse/Response/TransactionReference/CustomerContext").content
    country_info =~ /(\w+) to (\w+)/
    origin = $1
    destination = $2
    instance.service = UPSRateRequest.service_from_code(origin, destination, instance.code)
  end

  # USPS
  map(:all, "//RateV3Response/Package/Postage", {
    :price => "Rate",
    :service => "MailService",
    :code => "attribute::CLASSID"
  }) {|instance| instance.carrier = "USPS" }
  
  # International USPS
  map(:all, "//IntlRateResponse/Package/Service", {
    :price => "Postage",
    :service => "SvcDescription",
    :code => "attribute::ID"
  }) {|instance| instance.carrier = "USPS" }
  
  # FedEx
  # map()
end

