require File.dirname(__FILE__) + "/spec_helper"

describe UPSRateRequest do
  before(:each) do
    @request = UPSRateRequest.new({
      :weight => "5.6",
      :country => "US",
      :zip => "98105"
    })
  end

  it "creates xml" do
    xml = @request.to_xml_etc
    xml.should =~ /\<\?xml/
  end

  if ENV['DO_IT_LIVE']
    
    it "should get live rates" do
      $DEBUG = true # spit out xml for the request & response
      @request.do
      rates.should_not be_blank
    end
    
    it "should get live international rates" do
      $DEBUG = true
      rates = UPSRateRequest.new({
        :country => "CA",
        :weight => "5.00",
      }).do
      rates.should_not be_blank
    end
  end
  
end