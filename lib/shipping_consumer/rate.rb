class Rate
  include Consumer::Mapping
  attr_accessor :name, :code, :carrier, :context, :price, :service_id

  # UPS
  map(:all, "//RatingServiceSelectionResponse/RatedShipment", {
    :price => "TotalCharges/MonetaryValue",
    # :service => "Service",
    :code => "Service/Code"
  }) do |instance, node|
    
    country_info = node.find_first("//RatingServiceSelectionResponse/Response/TransactionReference/CustomerContext").content
    country_info =~ /(\w+) to (\w+)/
    origin = $1
    destination = $2

    instance.context = UPSRateRequest.context_from_code(origin, destination, instance.code)
    instance.name = UPSRateRequest.service_name_from_code(origin, destination, instance.code, instance.context)
    instance.carrier = "UPS"
    instance.service_id = instance.service.id
  end

  # Domestic USPS
  map(:all, "//RateV3Response/Package/Postage", {
    :price => "Rate",
    :name => "MailService",
    :code => "attribute::CLASSID"
  }) do |instance|
    instance.carrier = "USPS"
    instance.context = "Domestic"
    instance.service_id = instance.service.id
  end
  
  # International USPS
  map(:all, "//IntlRateResponse/Package/Service", {
    :price => "Postage",
    :name => "SvcDescription",
    :code => "attribute::ID"
  }) do |instance|
    instance.carrier = "USPS"
    instance.context = "International"
    instance.service_id = instance.service.id
  end

  def service
    @service ||= Service.find(self.service_id)
    @service ||= Service.find_by_attributes(
      :code => self.code,
      :carrier => self.carrier,
      :context => self.context
    )
  end
  
  # FedEx
  # map()
end

