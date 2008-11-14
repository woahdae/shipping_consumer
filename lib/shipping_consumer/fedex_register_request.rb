# === Vendor API Docs
# http://www.example.com/handy_docs
class FedexRegisterRequest < Consumer::Request
  response_class "FedexRegisterResponse"
  error_paths({
    :root    => "//Error",
    :code    => "//ErrorCode",
    :message => "//ErrorDescription"
  })
  yaml_defaults "shipping_consumer.yml", "fedex_register"
  required(
    :name, :company, :phone, :email, :address, :city, :state, :zip,
    :fedex_account, :fedex_url
  )
  defaults({
    # :country => 'US'
  })
  
  def url
    return "www.example.com/testing" if $TESTING
    
    "www.example.com"
  end

  def to_xml
    b.instruct!
    
    b.FDXSubscriptionRequest('xmlns:api' => 'http://www.fedex.com/fsmapi', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:noNamespaceSchemaLocation' => 'FDXSubscriptionRequest.xsd') { |b|
      b.RequestHeader { |b|
        b.CustomerTransactionIdentifier @transaction_identifier if @transaction_identifier # optional
        b.AccountNumber @fedex_account
      }
      b.Contact { |b|
        b.PersonName @name
        b.CompanyName @company
        b.Department @department if @department
        b.PhoneNumber @phone.gsub(/[^\d]/,"")
        b.tag! :"E-MailAddress", @email
      }
      b.Address { |b|
        b.Line1 @address
        b.Line2 @address2 if @address2
        b.City @city
        b.StateOrProvinceCode 
        b.PostalCode @zip
        b.CountryCode 
      }
    }
  end
end