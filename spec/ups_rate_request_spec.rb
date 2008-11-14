require File.dirname(__FILE__) + "/spec_helper"

describe UPSRateRequest do

  if ENV['DO_IT_LIVE']
    
    it "should get live rates" do
      $DEBUG = true # spit out xml for the request & response
      rates = UPSRateRequest.new({
        :zip => "98125",
        :country => "US",
        :weight => "5.00",
      }).do
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