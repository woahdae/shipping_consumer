require File.dirname(__FILE__) + "/spec_helper"

describe UPSRateRequest do
  
  it "should get rates with a canned response" do
    file = "spec/xml/ups_rate_response.xml"
    xml = File.read("#{file}")
    raise "need to put example response in #{file}" if xml.blank?

    response = mock("HTTPResponse", :body => xml)
    http = mock("http", :post => response)
    http.stub!(:use_ssl=)
    http.stub!(:verify_mode=)
    Net::HTTP.should_receive(:new).and_return(http)
    
    do_request
  end

  if ENV['DO_IT_LIVE']
    it "should get live rates" do
      $DEBUG = true # spit out xml for the request & response
      do_request
    end
    
    it "should get live international rates" do
      $DEBUG = true
      do_request({
        :country => "CA",
        :weight => "5.00",
      })
    end
  end
  
  def do_request(args = nil)
    args ||= {
      :zip => "98125",
      :country => "US",
      :weight => "5.00",

      # optional
      # :city => "Seattle",
      # :state => "WA",
      # :service => "all"
    }
    raise "need to populate args for request" if args.empty?
    
    rates = UPSRateRequest.new(args).do

    rates.should_not be_blank
  end

end