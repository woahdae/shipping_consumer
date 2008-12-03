class Rate
  include Consumer::Mapping
  attr_accessor :service, :code, :price, :carrier, :id, :context
  
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
    instance.context = UPSRateRequest.context_from_code(origin, destination, instance.code)
    instance.service = UPSRateRequest.service_from_code(origin, destination, instance.code, instance.context)
    instance.set_method_id
  end

  # Domestic USPS
  map(:all, "//RateV3Response/Package/Postage", {
    :price => "Rate",
    :service => "MailService",
    :code => "attribute::CLASSID"
  }) do |instance|
    instance.carrier = "USPS"
    instance.context = "Domestic"
  end
  
  # International USPS
  map(:all, "//IntlRateResponse/Package/Service", {
    :price => "Postage",
    :service => "SvcDescription",
    :code => "attribute::ID"
  }) do |instance|
    instance.carrier = "USPS"
    instance.context = "International"
  end
  
  def set_method_id
    self.id = RateRequest.id_from_method(
      :code => self.code,
      :service => self.service,
      :carrier => self.carrier,
      :context => self.context
    )
  end
  
  # FedEx
  # map()
end

