# === Attributes (& defaults, * = required)
# * :access_license_number
# * :city
# * :country*
# * :currency_code        ("US") (required when insured_value)
# * :customer_type        ("wholesale")
# * :height               (0)
# * :insured_value        (0)    (required when currency_code)
# * :length               (0)
# * :measure_units        ("IN")
# * :package              ("your_packaging")
# * :password
# * :pickup_type          ("daily_pickup")
# * :sender_city
# * :sender_country
# * :sender_state
# * :sender_zip
# * :service               ("all")
# * :state
# * :user_id
# * :weight*
# * :weight_units         ("LBS")
# * :width                (0)
# * :zip*
# === Vendor API Docs
# http://www.ups.com/gec/techdocs/pdf/dtk_RateXML_V1.zip
class UPSRateRequest < Consumer::Request
  response_class "Rate"
  yaml_defaults "shipping_consumer.yml", "ups"

  error_paths({
    :root    => "//Error",
    :code    => "//ErrorCode",
    :message => "//ErrorDescription"
  })

  def required
    ret = [
      :access_license_number,
      :sender_country,
      :country,
      :weight
    ]

    ret += [:zip, :sender_zip] if !self.international?
  end
  
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
    return "https://wwwcie.ups.com/ups.app/xml/Rate" if $TESTING
    
    "https://www.ups.com/ups.app/xml/Rate"
  end

  API_VERSION = "1.0001"
  
  PACKAGES = {
    "ups_envelope" => "01",
    "your_packaging" => "02",
    "ups_tube" => "03",
    "ups_pak" => "04",
    "ups_box" => "21",
    "fedex_25_kg_box" => "24",
    "fedex_10_kg_box" => "25"
  }

  SERVICES = {
    "next_day" => "01",
    "2_day" => "02",
    "ground" => "03",
    "worldwide_express" => "07",
    "worldwide_expedited" => "08",
    "standard" => "11",
    "3_day" => "12",
    "next_day_saver" => "13",
    "next_day_early" => "14",
    "worldwide_express_plus" => "54",
    "2_day_early" => "59",
    "all" => "all"
  }
  
  # UPS-Specific types
  
  ### From page 99 of the doc PDF.
  SERVICE_CODES = {
    "US Domestic" => {
      "01" => "UPS Next Day Air",
      "02" => "UPS Second Day Air",
      "03" => "UPS Ground",
      "12" => "UPS Three-Day Select",
      "13" => "UPS Next Day Air Saver",
      "14" => "UPS Next Day Air Early A.M.",
      "59" => "UPS Second Day Air A.M.",
      "65" => "UPS Saver"
    },
    "US Origin" => {
      # Although the documentation says these exist,
      # in actuality they are not ever used for anything
      # but freight.
      # "01" => "UPS Next Day Air",
      # "02" => "UPS Second Day Air",
      # "03" => "UPS Ground",
      "07" => "UPS Worldwide Express",
      "08" => "UPS Worldwide Expedited",
      "11" => "UPS Standard",
      # "12" => "UPS Three-Day Select",
      # "14" => "UPS Next Day Air Early A.M.",
      "54" => "UPS Worldwide Express Plus"
      # "59" => "UPS Second Day Air A.M.",
      # "65" => "UPS Saver"
    },
    "Puerto Rico Origin" => {
      "01" => "UPS Next Day Air",
      "02" => "UPS Second Day Air",
      "03" => "UPS Ground",
      "07" => "UPS Worldwide Express",
      "08" => "UPS Worldwide Expedited",
      "14" => "UPS Next Day Air Early A.M.",
      "54" => "UPS Worldwide Express Plus",
      "65" => "UPS Saver"
    },
    "Canada Origin" => {
      "01" => "UPS Express",
      "02" => "UPS Expedited",
      "07" => "UPS Worldwide Express",
      "08" => "UPS Worldwide Expedited",
      "11" => "UPS Standard",
      "12" => "UPS Three-Day Select",
      "13" => "UPS Saver",
      "14" => "UPS Express Early A.M.",
      "54" => "UPS Worldwide Express Plus",
      "65" => "UPS Saver"
    },
    "Mexico Origin" => {
      "07" => "UPS Express",
      "08" => "UPS Expedited",
      "54" => "UPS Express Plus",
      "65" => "UPS Saver"
    },
    "Polish Domestic" => {
      "07" => "UPS Express",
      "08" => "UPS Expedited",
      "11" => "UPS Standard",
      "54" => "UPS Worldwide Express Plus",
      "65" => "UPS Saver",
      "82" => "UPS Today Standard",
      "83" => "UPS Today Dedicated Courrier",
      "84" => "UPS Today Intercity",
      "85" => "UPS Today Express",
      "86" => "UPS Today Express Saver"
    },
    "EU Origin" => {
      "07" => "UPS Express",
      "08" => "UPS Expedited",
      "11" => "UPS Standard",
      "54" => "UPS Worldwide Express Plus",
      "65" => "UPS Saver"
    },
    "Other International Origin" => {
      "07" => "UPS Express",
      "08" => "UPS Worldwide Expedited",
      "11" => "UPS Standard",
      "54" => "UPS Worldwide Express Plus",
      "65" => "UPS Saver"
    },
    "Freight" => {
      "TDCB" => "Trade Direct Cross Border",
      "TDA"  => "Trade Direct Air",
      "TDO"  => "Trade Direct Ocean",
      "308"  => "UPS Freight LTL",
      "309"  => "UPS Freight LTL Guaranteed",
      "310"  =>  "UPS Freight LTL Urgent"
    }
  }
  
  def self.context(origin, destination)
    context = case origin
    when "US"
      destination == "US" ? 'US Domestic' : 'US Origin'
    when "PR"
      'Puerto Rico Origin'
    when "CA"
      'Canada Origin'
    when "MX"
      'Mexico Origin'
    when "PL"
      destination == "PL" ? 'Polish Origin' : 'Other International Origin'
    when *EU_COUNTRY_CODES
      'EU Origin'
    else
      'Other International Origin'
    end
    
    return context
  end
  
  def self.service_name_from_code(origin, destination, code, context = nil)
    context ||= context(origin, destination)
    return SERVICE_CODES[context][code]
  end
  
  def self.service_from_code(origin, destination, code)
    context = context(origin, destination)
    return Service.find_by_attributes(
      :carrier => "UPS",
      :context => context,
      :code => code
    )
  end 
  
  def service_from_id(id)
    RateRequest::SERVICE_IDS[id][:service]
  end
  
  
  ### End shipping codes ###
  
  EU_COUNTRY_CODES = ["GB", "AT", "BE", "BG", "CY", "CZ", "DK", "EE", "FI", "FR", "DE", "GR", "HU", "IE", "IT", "LV", "LT", "LU", "MT", "NL", "PL", "PT", "RO", "SK", "SI", "ES", "SE"]
  
  PAYMENT_TYPES = {
    'prepaid' => 'Prepaid',
    'consignee' => 'Consignee',
    'bill_third_party' => 'BillThirdParty',
    'freight_collect' => 'FreightCollect'
  }


  PICKUP_TYPES = {
    'daily_pickup' => '01',
    'customer_counter' => '03',
    'one_time_pickup' => '06',
    'on_call' => '07',
    'suggested_retail_rates' => '11',
    'letter_center' => '19',
    'air_service_center' => '20'
  }

  CUSTOMER_TYPES = {
    'wholesale' => '01',
    'ocassional' => '02',
    'retail' => '04'
  }
  
  def before_to_xml
    @code ||= SERVICES[@service]
    @request_type = @code == "all" ? "Shop" : "Rate"
    
    @weight =  [1.00, @weight.to_f].max
  end
  
  def to_xml
    b.instruct!

    b.AccessRequest {
      b.AccessLicenseNumber @access_license_number
      b.UserId @user_id
      b.Password @password
    }
    
    b.instruct!

    b.RatingServiceSelectionRequest { 
      b.Request {
        b.TransactionReference {
          b.CustomerContext "#{@sender_country} to #{@country}"
          b.XpciVersion API_VERSION
        }
        b.RequestAction 'Rate'
        b.RequestOption @request_type
      }
      b.CustomerClassification {
        b.Code CUSTOMER_TYPES[@customer_type]
      }
      b.PickupType {
        b.Code PICKUP_TYPES[@pickup_type]
      }
      b.Shipment {
        b.Shipper {
          b.Address {
            b.PostalCode @sender_zip
            b.CountryCode @sender_country
            b.City @sender_city 
            b.StateProvinceCode @sender_state
          }
        }
        b.ShipTo {
          b.Address {
            b.PostalCode @zip
            b.CountryCode @country
            b.City @city
            b.StateProvinceCode @state 
          }
        }
        b.Service {
          b.Code @code
        }
        b.Package {
          b.PackagingType {
            b.Code PACKAGES[@package]
            b.Description 'Package'
          }
          b.Description 'Rate Shopping'
          b.PackageWeight {
            b.Weight @weight
            b.UnitOfMeasurement {
              b.Code @weight_units
            }
          }
          b.Dimensions {
            b.UnitOfMeasurement {
              b.Code @measure_units
            }
            b.Length @length
            b.Width @width
            b.Height @height
          }
          b.PackageServiceOptions {
            b.InsuredValue {
              b.CurrencyCode @currency_code
              b.MonetaryValue @insured_value
            }
          }
        }
      }
    }
        
  end
  
  def international?
    @country && @country != "US"
  end
  
end