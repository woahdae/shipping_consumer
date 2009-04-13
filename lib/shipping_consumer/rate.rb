class Rate
  include Consumer::Mapping
  attr_accessor :name, :code, :carrier, :context, :price, :service_id

  # UPS
  map(:all, "//RatingServiceSelectionResponse/RatedShipment", {
    :price => "TotalCharges/MonetaryValue",
    # :service => "Service",
    :code => "Service/Code"
  }) do |instance, node|
    instance.carrier = "UPS"

    origin, destination = country_info_from_custom_element(node, "//RatingServiceSelectionResponse/Response/TransactionReference/CustomerContext")

    instance.context = UPSRateRequest.context(origin, destination)
    instance.name = UPSRateRequest.service_name_from_code(origin, destination, instance.code, instance.context)
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
  
  # Fedex
  map(:all, "//v5:RateReplyDetails", {
    :price => "v5:RatedShipmentDetails/v5:ShipmentRateDetail/v5:TotalBaseCharge/v5:Amount",
    :name  => "v5:ServiceType",
    :code  => "v5:ServiceType"
  }) do |instance, node|
    instance.carrier = "Fedex"
    origin, destination = country_info_from_custom_element(node, "//v5:TransactionDetail/v5:CustomerTransactionId")
    instance.context = FedexRateRequest.context(origin, destination)
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
  
  def self.country_info_from_custom_element(node, xpath)
    country_info = node.find_first(xpath).content
    country_info =~ /(\w+) to (\w+)/
    origin = $1
    destination = $2
    
    return origin, destination
  end
end

