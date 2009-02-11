require File.dirname(__FILE__) + "/spec_helper"

describe RateRequest do
  
  if ENV['DO_IT_LIVE']
    describe "get_multiple" do
      it "should get rates from multiple carriers" do
        $DEBUG = true
        rates = RateRequest.get_multiple({
          :zip => "98125",
          :country => "US",
          :weight => "5.6"
        })
              
        rates.size.should_not be_blank
      end
      
      it "should get international rates from multiple carriers" do
        $DEBUG = true
        rates = RateRequest.get_multiple({
          :country => "CA",
          :weight => "5.6",
          :zip => "N1R7J5"
        })
        
        rates.size.should_not be_blank
      end
    end
  end

end