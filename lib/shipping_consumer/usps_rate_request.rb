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
# * :country    (for international requests)
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
  
  error_paths({
    :root    => "//Error",
    :code    => "//Source",
    :message => "//Description"
  })
  
  yaml_defaults "shipping_consumer.yml", "usps"
  
  def required
    ret = [
      :user_id,
      :sender_zip,
      :service,
      :weight
    ]
    
    if self.international?
      ret << :country
      ret << :intl_mail_type
    else
      ret << :zip 
    end
    
    return ret
  end
  
  defaults({
    :service => "all",
    :machinable => "false",
    :size => "regular",
    :intl_mail_type => "Package",
  })
  
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
  
  def to_xml
    pounds, ounces = Helper.weight_in_lbz_oz(@weight)
    if self.international?
      request_type = :IntlRate
      @mail_type = @intl_mail_type
      @zip = nil
      @sender_zip = nil
      @size = nil
      @service = nil
      @first_class_mail_type = nil
    else
      request_type = :RateV3
    end
    
    Helper.upcase!(
      @mail_type,
      @service,
      @size,
      @container
    )
    
    Helper.five_digit_zip!(
      @sender_zip,
      @zip
    )
    
    xml = begin
      b.instruct!
      
      b.tag!("#{request_type}Request", :USERID => @user_id) {
        b.Package(:ID => "0") {
          b.Service @service
          b.ZipOrigination @sender_zip
          b.ZipDestination @zip
          b.Pounds pounds
          b.Ounces ounces
          b.Size @size
          b.Machinable @machinable
          b.MailType @mail_type
          b.Country @country
          b.FirstClassMailType @first_class_mail_type
          b.Container @package
        }
      }
    end
    
    return "API=#{request_type}&XML=" + xml
  end
  
  def international?
    @country && @country != "US"
  end
  
end