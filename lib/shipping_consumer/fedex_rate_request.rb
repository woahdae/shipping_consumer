class FedexRateRequest < Consumer::Request
  response_class "Rate"
  error_paths({
    :root    => "//Error",
    :code    => "//ErrorCode",
    :message => "//ErrorDescription"
  })
  yaml_defaults "shipping_consumer.yml", "fedex"

  def required
    # these are in shipping_consumer.yml
    required = [:sender_zip, :sender_country]

    # these must be passed in
    required += [:zip,:weight]
  end

  defaults({
    :service          => "all",
    :weight_units     => 'LB', # or KG
    :country          => "US"
  })
  
  def url
    return "https://gatewaybeta.fedex.com:443/xml" if $TESTING
    
    "https://gateway.fedex.com:443/xml"
  end
  
  PACKAGES = {
    "box"            => "FEDEX_BOX",
    "envelope"       => "FEDEX_ENVELOPE",
    "package"        => "FEDEX_PAK",
    "tube"           => "FEDEX_TUBE",
    "your_packaging" => "YOUR_PACKAGING"
  }
  
  SERVICES = {
    "all"                => nil,
    "ground"             => "FEDEX_GROUND",
    "priority_overnight" => "PRIORITY_OVERNIGHT",
    "standard_overnight" => "STANDARD_OVERNIGHT",
    "2_day"              => "FEDEX_2_DAY",
    "express_saver"      => "FEDEX_EXPRESS_SAVER",
    "overnight"          => "FIRST_OVERNIGHT"
  }
  
  SERVICE_CODES = {
    "Domestic" => {
      "FEDEX_GROUND"        => "Ground",
      "STANDARD_OVERNIGHT"  => "Standard Overnight",
      "PRIORITY_OVERNIGHT"  => "Priority Overnight",
      "FEDEX_2_DAY"         => "2-Day",
      "FEDEX_EXPRESS_SAVER" => "Express Saver",
      "FIRST_OVERNIGHT"     => "Overnight"
    },
    "International" => {
      "INTERNATIONAL_PRIORITY" => "International Priority",
      "INTERNATIONAL_ECONOMY"  => "International Economy",
      "FEDEX_GROUND"           => "Ground" # usually only for US-Canada
    }
  }

  def before_to_xml
    if $TESTING
      @account_number = @test_account_number
      @meter_number   = @test_meter_number
      @key            = @test_key
      @password       = @test_password
    end
    
    @weight = '1.0' if @weight.to_f < 1.0
  end

  def to_xml
    b.instruct!

    b.RateRequest('xmlns' => 'http://fedex.com/ws/rate/v5') {
      b.WebAuthenticationDetail {
        b.UserCredential {
          b.Key @key
          b.Password @password
        }
      }
      b.ClientDetail {
        b.AccountNumber @account_number
        b.MeterNumber @meter_number
      }
      b.TransactionDetail {
        b.CustomerTransactionId "#{@sender_country} to #{@country}"
      }
      b.Version {
        b.ServiceId "crs"
        b.Major 5
        b.Intermediate 0
        b.Minor 0
      }
    
      b.RequestedShipment {
        b.ServiceType SERVICES[@service]
        b.Shipper {
          b.Address {
            b.StateOrProvinceCode @sender_state
            b.PostalCode @sender_zip
            b.CountryCode @sender_country
          }
        }
        b.Recipient {
          b.Address {
            b.StateOrProvinceCode @state
            b.PostalCode @zip
            b.CountryCode @country
          }
        }
        b.PackageDetail "INDIVIDUAL_PACKAGES"
        b.RequestedPackages {
          b.Weight {
            b.Units "LB"
            b.Value @weight
          }
        }
      }
    }
  end
  
  def self.service_name_from_code(origin, destination, code, context = nil)
    context ||= context(origin, destination)
    return SERVICE_CODES[context][code]
  end
  
  def self.context(origin, destination)
    context = if origin == "US"
      destination == "US" ? 'Domestic' : 'International'
    else
      "International"
    end
    
    return context
  end
end