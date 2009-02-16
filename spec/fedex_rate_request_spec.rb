require File.dirname(__FILE__) + "/spec_helper"

describe FedexRateRequest do

  it "creates xml" do
    fedex_rate_request = FedexRateRequest.new({
      :weight => "5.6",
      :zip => "98105"
    })
    xml = fedex_rate_request.to_xml_etc
    xml.should =~ /\<\?xml/
  end
  
  # run "DO_IT_LIVE=true spec spec" to contact the api
  if ENV['DO_IT_LIVE']
    
    it "contacts the live api and returns FedexRate instance(s)" do
      $DEBUG = true # spit out xml for the request & response
      
      fedex_rate = FedexRateRequest.new({
        :weight => "0.005",
        :zip => "98105"
      }).do
      fedex_rate.should_not be_blank
    end

    # it "should get live international rates" do
    #   $DEBUG = true
    #   rates = FedexRateRequest.new({
    #     :weight => "5.6",
    #     # :country => "BR",
    #     # :zip => "40301-110"
    #     :country => "CA",
    #     :zip => "N1R7J5"
    #   }).do
    #   rates.should_not be_blank
    # end

  end

end