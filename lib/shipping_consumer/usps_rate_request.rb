require File.dirname(__FILE__) + '/rate_request'

# === Attributes (& defaults, * = required)
# * :first_class_mail_type
# * :height
# * :intl_mail_type        ("Package", required if international)
# * :length
# * :machinable            ("false")
# * :package
# * :sender_zip
# * :service               ("all")
# * :size                  ("regular")
# * :user_id
# * :weight*
# * :width
# * :zip*
# * :country               two letter code (only required for international requests)
# === Required rules summary
# Width, Length, Height, and Girth Required when :service => priority and :size => large
# 
# Machinable required when:
# * service => first_class and mail_type => (letter or flat)
# * service => parcel_post
# * service => all
# * service => online 
# 
# A bunch of stuff required when :package is present
# === Vendor API Docs
# http://www.usps.com/webtools/htm/Rate-Calculators-v2-1.htm
class USPSRateRequest < Consumer::Request
  include ShippingConsumer
  response_class "Rate"
  yaml_defaults "shipping_consumer.yml", "usps"
  
  error_paths({
    :root    => "//Error",
    :code    => "//Source",
    :message => "//Description"
  })
  
  def required
    ret = [
      :user_id,
      :weight
    ]
    
    if self.international?
      ret << :country
      ret << :mail_type
    else # domestic
      ret << :zip
      ret << :sender_zip
      ret << :service
    end
    
    return ret
  end
  
  def defaults
    ret = {
      :service => "all",
      :machinable => "false",
      :size => "regular",
    }
    
    if self.international?
      ret[:mail_type] =  "Package"
      ret[:request_type] = :IntlRate
    else # domestic
      ret[:request_type] = :RateV3
    end
    
    return ret
  end
  
  def abort?
    return non_domestic_origin?
  end
  
  # they have a test url, but it's crippled and acts different than the production url.
  url "http://production.shippingapis.com/ShippingAPI.dll"
  
  SERVICES = [
    :first_class,
    :priority,
    :express,
    :bpm,
    :parcel,
    :media,
    :library,
    :online,
    :all
  ]
  
  # Use to specify special containers or container attributes that may affect postage; otherwise, leave blank. 
  # Default: VARIABLE
  PACKAGES = [
    :variable,
    :flat_rate_box,
    :flat_rate_envelope,
    :flat_rate_box,
    :rectangular,
    :nonrectangular
  ]

  ### USPS specific types ###
  
  # required when service => first_class
  FIRST_CLASS_MAIL_TYPES = [
    :letter,
    :flat,
    :parcel
  ]
  
  INTL_MAIL_TYPES = [
    "Package",
    "Postcards or aerogrammes",
    "Matter for the blind",
    "Envelope"
  ]
  
  # You can get these from http://www.usps.com/webtools/htm/RateCalculatorsv20.htm.
  # Note that we've updated them as per what we see from the live API
  SERVICE_CODES = {
    "Domestic" => {
      "0"  => "First-Class Mail",
      "1"  => "Priority Mail",
      "2"  => "Express Mail Hold for Pickup",
      "3"  => "Express Mail",
      "4"  => "Parcel Post",
      "5"  => "Bound Printed Matter",
      "6"  => "Media Mail",
      "7"  => "Library Mail",
      "12" => "First-Class Postcard Stamped",
      "13" => "Express Mail Flat-Rate Envelope",
      "16" => "Priority Mail Flat-Rate Envelope",
      "17" => "Priority Mail Flat-Rate Box",
      "18" => "Priority Mail Keys and IDs",
      "19" => "First-Class Keys and IDs",
      "22" => "Priority Mail Large Flat-Rate Box",
      "23" => "Express Mail Sunday/Holiday Guarantee",
      "25" => "Express Mail Flat-Rate Envelope Sunday/Holiday Guarantee",
      "27" => "Express Mail Flat-Rate Envelope Hold For Pickup"
    },
    "International" => {
      "1"  => "Express Mail International",
      "2"  => "Priority Mail International",
      "4"  => "Global Express Guaranteed",
      "5"  => "Global Express Guaranteed Document",
      "6"  => "Global Express Guaranteed Non-Document Rectangular",
      "7"  => "Global Express Guaranteed Non-Document Non-Rectangular",
      "8"  => "Priority Mail International Flat-Rate Envelope",
      "9"  => "Priority Mail International Flat-Rate Box",
      "10" => "Express Mail International Flat-Rate Envelope",
      "11" => "Priority Mail International Large Flat-Rate Box",
      "12" => "Global Express Guaranteed Envelope",
      "13" => "First Class Mail International Letters",
      "14" => "First Class Mail International Flats",
      "15" => "First Class Mail International Parcels",
      "21" => "PostCards"
    }
  }
  
  # May be left blank in situations that do not require a Size. Defined as 
  # follows: 
  # * REGULAR: package length plus girth is 84 inches or less; 
  # * LARGE: package length plus girth measure more than 84 inches but not more than 108 inches; 
  # * OVERSIZE: package length plus girth is more than 108 but not more than 130 inches. 
  # Default: REGULAR
  SIZES = [
    :regular,
    :large,
    :oversize
  ]
  
  REQUEST_TYPES = [
    :IntlRate,
    :RateV3
  ]
  
  NON_ISO_CODES = {
    "BA" => "Bosnia-Herzegovina",
    "CD" => "Congo, Democratic Republic of the",
    "CG" => "Congo (Brazzaville),Republic of the",
    "CI" => "Côte d'Ivoire (Ivory Coast)",
    "CK" => "Cook Islands (New Zealand)",
    "FK" => "Falkland Islands",
    "GB" => "Great Britain and Northern Ireland",
    "GE" => "Georgia, Republic of",
    "IR" => "Iran",
    "KN" => "Saint Kitts (St. Christopher and Nevis)",
    "KP" => "North Korea (Korea, Democratic People's Republic of)",
    "KR" => "South Korea (Korea, Republic of)",
    "LA" => "Laos",
    "LY" => "Libya",
    "MC" => "Monaco (France)",
    "MD" => "Moldova",
    "MK" => "Macedonia, Republic of",
    "MM" => "Burma",
    "PN" => "Pitcairn Island",
    "RU" => "Russia",
    "SK" => "Slovak Republic",
    "TK" => "Tokelau (Union) Group (Western Samoa)",
    "TW" => "Taiwan",
    "TZ" => "Tanzania",
    "VA" => "Vatican City",
    "VG" => "British Virgin Islands",
    "VN" => "Vietnam",
    "WF" => "Wallis and Futuna Islands",
    "WS" => "Western Samoa"
  }
  
  USPS_COUNTRY_CODES = RateRequest::COUNTRY_CODES.merge(NON_ISO_CODES)
  
  def before_to_xml
    @pounds, @ounces = ShippingHelper.weight_in_lbz_oz(@weight)

    # USPS really doesn't like extraneous data
    if self.international?
      @zip = nil
      @size = nil
      @service = nil
      @sender_zip = nil
      @first_class_mail_type = nil
      @country = USPS_COUNTRY_CODES[@country]
    else
      @country = nil
    end
    
    ShippingHelper.upcase!(
      @mail_type,
      @service,
      @size,
      @container
    )
    
    ShippingHelper.five_digit_zip!(
      @sender_zip,
      @zip
    )
  end
  
  def to_xml
    xml = begin
      b.instruct!
      
      b.tag!("#{@request_type}Request", :USERID => @user_id) {
        b.Package(:ID => "0") {
          b.Service @service
          b.ZipOrigination @sender_zip
          b.ZipDestination @zip
          b.Pounds @pounds
          b.Ounces @ounces
          b.Size @size
          b.Machinable @machinable
          b.MailType @mail_type
          b.Country @country
          b.FirstClassMailType @first_class_mail_type
          b.Container @package
        }
      }
    end
    
    return "API=#{@request_type}&XML=" + xml
  end
  
  def non_domestic_origin?
    @sender_country && @sender_country != "US"
  end
  
  def international?
    @country && @country != "US"
  end
  
end