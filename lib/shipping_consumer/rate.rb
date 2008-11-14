class Rate
  include Consumer::Mapping
  attr_accessor :service, :code, :price, :carrier
  
  # UPS
  map(:all, "//RatingServiceSelectionResponse/RatedShipment", {
    :price => "TotalCharges/MonetaryValue",
    # :service => "Service",
    :code => "Service/Code"
  }) {|instance| instance.carrier = "UPS" }

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

