# === Vendor API Docs
# http://www.example.com/handy_docs
class FedexRateRequest < Consumer::Request
  response_class "Rate"
  error_paths({
    :root    => "//Error",
    :code    => "//ErrorCode",
    :message => "//ErrorDescription"
  })
  yaml_defaults "shipping_consumer.yml", "fedex"
  required(
  # these are in shipping.yml
  :access_license_number,
  :sender_zip,
  :sender_country,

  # these must be passed in
  :zip,
  :country,
  :weight
  )
  defaults({
    :service        => "all",
    :package        => "your_packaging",
    :length         => 0,
    :width          => 0,
    :height         => 0,
    :customer_type  => "wholesale",
    :pickup_type    => "daily_pickup",
    :weight_units   => 'LBS', # or KGS
    :measure_units  => 'IN'
  })
  
  def url
    return "www.example.com/testing" if $TESTING
    
    "www.example.com"
  end

  PACKAGES = {
    "fedex_envelope" => "FEDEXENVELOPE",
    "fedex_pak" => "FEDEXPAK",
    "fedex_box" => "FEDEXBOX",
    "fedex_tube" => "FEDEXTUBE",
    "fedex_10_kg_box" => "FEDEX10KGBOX",
    "fedex_25_kg_box" => "FEDEX25KGBOX",
    "your_packaging" => "YOURPACKAGING"
  }
  
  SERVICES = {
    "priority" => "PRIORITYOVERNIGHT",
    "2_day" => "FEDEX2DAY",
    "standard_overnight" => "STANDARDOVERNIGHT",
    "first_overnight" => "FIRSTOVERNIGHT",
    "express_saver" => "FEDEXEXPRESSSAVER",
    "1_day_freight" => "FEDEX1DAYFREIGHT",
    "2_day_freight" => "FEDEX2DAYFREIGHT",
    "3_day_freight" => "FEDEX3DAYFREIGHT",
    "international_priority" => "INTERNATIONALPRIORITY",
    "international_economy" => "INTERNATIONALECONOMY",
    "international_first" => "INTERNATIONALFIRST",
    "international_priority_freight" => "INTERNATIONALPRIORITYFREIGHT",
    "international_economy_freight" => "INTERNATIONALECONOMYFREIGHT",
    "home_delivery" => "GROUNDHOMEDELIVERY",
    "ground" => "FEDEXGROUND",
    "international_ground_service" => "INTERNATIONALGROUND"
  }

  PAYMENT_TYPES = {
    'sender' => 'SENDER',
    'recipient' => 'RECIPIENT',
    'third_party' => 'THIRDPARTY',
    'collect' => 'COLLECT'
  }

  # Fedex-Specific types

  DROP_OFF_TYPES = {
    'regular_pickup' => 'REGULARPICKUP',
    'request_courier' => 'REQUESTCOURIER',
    'dropbox' => 'DROPBOX',
    'business_service_center' => 'BUSINESSSERVICECENTER',
    'station' => 'STATION'
  }

  TRANSACTION_TYPES = {
    'rate_ground'           =>  ['022','FDXG'],
    'rate_express'          =>  ['022','FDXE'],
    'rate_services'         =>  ['025',''],
    'ship_ground'           =>  ['021','FDXG'],
    'ship_express'          =>  ['021','FDXE'],
    'cancel_express'        =>  ['023','FDXE'],
    'cancel_ground'         =>  ['023','FDXG'],
    'close_ground'          =>  ['007','FDXG'],
    'service_available'     =>  ['019','FDXE'],
    'fedex_locater'         =>  ['410',''],
    'subscribe'             =>  ['211',''],
    'sig_proof_delivery'    =>  ['402',''],
    'track'                 =>  ['405',''],
    'ref_track'             =>  ['403','']
  }
  

  def to_xml
    b.instruct!
    
    b.FDXRateRequest('xmlns:api' => 'http://www.fedex.com/fsmapi', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:noNamespaceSchemaLocation' => 'FDXRateRequest.xsd') { |b|
      b.RequestHeader { |b|
        b.AccountNumber @fedex_account
        b.MeterNumber @fedex_meter
        b.CarrierCode TRANSACTION_TYPES[@transaction_type][1]
      }
      b.ShipDate @ship_date unless @ship_date.blank?
      b.DropoffType @dropoff_type || 'REGULARPICKUP'
      b.Service SERVICES[@service] || SERVICES['ground'] # default to ground service
      b.Packaging PACKAGES[@package] || 'YOURPACKAGING'
      b.WeightUnits @weight_units || 'LBS'
      b.Weight @weight
      b.ListRate true # tells fedex to return list rates as well as discounted rates
      b.OriginAddress { |b|
        b.StateOrProvinceCode self.class.state_from_zip(@sender_zip)
        b.PostalCode @sender_zip
        b.CountryCode @sender_country_code || "US"
      }
      b.DestinationAddress { |b|
        b.StateOrProvinceCode self.class.state_from_zip(@zip)
        b.PostalCode @zip
        b.CountryCode @country || "US"
      }
      b.Payment { |b|
        b.PayorType PAYMENT_TYPES[@payment_type] || 'SENDER'
      }
      b.PackageCount @package_total || '1'
    }

    get_response @fedex_url
  end
end