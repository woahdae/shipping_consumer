require File.dirname(__FILE__) + "/spec_helper"

describe USPSRateRequest do
  
  it "creates xml" do
    request = USPSRateRequest.new({
      :weight => "5.6",
      :zip => "98105"
    })
    xml = request.to_xml_etc
    xml.should =~ /\<\?xml/
  end

  if ENV['DO_IT_LIVE']
    
    it "should get live rates" do
      $DEBUG = true # spit out xml for the request & response
      rates = USPSRateRequest.new({
        :weight => "5.6",
        :zip => "98105"
      }).do
      rates.should_not be_blank
    end
    
    it "should get live international rates" do
      $DEBUG = true
      rates = USPSRateRequest.new({
        :weight => "5.6",
        :country => "VG"
      }).do
      rates.should_not be_blank
    end
    
    it "should get international rates to one of USPS's non-ISO countries" do
      $DEBUG = true
      rates = USPSRateRequest.new({
        :country => "BA",
        :weight => "5.6"
      }).do
      rates.should_not be_blank
    end

    it "should get no rates if the origin country is non-us" do
      $DEBUG = true
      rates = USPSRateRequest.new({
        :sender_country => "CA",
        :country => "US",
        :zip => "98105",
        :weight => "5.6"
      }).do
      rates.should be_blank
    end
    
  end

end