require File.dirname(__FILE__) + "/spec_helper"

describe USPSRateRequest do
  
  it "should get rates with a canned response" do
    file = "spec/xml/usps_rate_response.xml"
    xml = File.read("#{file}")
    raise "need to put example response in #{file}" if xml.blank?

    response = mock("HTTPResponse", :body => xml)
    http = mock("http", :post => response)
    http.stub!(:use_ssl=)
    http.stub!(:verify_mode=)
    Net::HTTP.should_receive(:new).and_return(http)
    
    do_request
  end

  # run "DO_IT_LIVE=true spec spec" to contact the api
  if ENV['DO_IT_LIVE']
    it "should get live rates" do
      $DEBUG = true # spit out xml for the request & response
      do_request
    end
    
    it "should get live international rates" do
      $DEBUG = true # spit out xml for the request & response
      do_request({
        :weight => "5.6",
        :country => "British Virgin Islands",
        :service => "all"
      })
    end
  end
  
  def do_request(args = nil)
    args ||= {
      :weight => "5.6",
      :zip => "98105",
      :service => "All"
    }
    raise "need to populate args for request" if args.empty?
    
    result = USPSRateRequest.new(args).do
    
    result.should_not be_blank
  end

end