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
    @request_type = @service == "all" ? "Shop" : "Rate"
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
          b.CustomerContext 'Rating and Service'
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
          b.Code SERVICES[@service]
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