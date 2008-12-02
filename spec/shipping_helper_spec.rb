require File.dirname(__FILE__) + "/spec_helper"

describe ShippingConsumer::ShippingHelper do
  describe "weight_in_lbz_oz" do
    it "should convert a weight into lbs and oz" do
      ShippingConsumer::ShippingHelper.weight_in_lbz_oz("5.6").should == [5, 10]
    end
  end
  
  describe "upcase!" do
    it "should upcase and replace _ with ' '" do
      string = "walk_this_way"
      ShippingConsumer::ShippingHelper.upcase!(string)
      string.should == "WALK THIS WAY"
    end
    
    it "should work even when it was already upcased" do
      string = "UPCASED"
      ShippingConsumer::ShippingHelper.upcase!(string)
      string.should == "UPCASED"
    end
  end
  
  describe "five_digit_zip!" do
    it "should strip down long zips to only 5 digits" do
      zip = "98105-1234"
      ShippingConsumer::ShippingHelper.five_digit_zip!(zip)
      zip.should == "98105"
    end
  end
  
  describe "rates_by_carrier" do
    it "should return a hash of the form 'carrier' => [rates]" do
      rate1 = Rate.new
      rate1.carrier = "UPS"
      rate1.price = "5.00"
      rate2 = Rate.new
      rate2.carrier = "UPS"
      rate2.price = "4.00"
      rate3 = Rate.new
      rate3.carrier = "USPS"
      rate3.price = "6.00"
      rates = [rate1, rate2, rate3]
      expected = {"UPS" => [rate2, rate1], "USPS" => [rate3]}
      ShippingConsumer::ShippingHelper.rates_by_carrier(rates).should == expected
    end
  end

  describe "methods_by_carrier_and_context" do
    it "should return a hash of the form 'carrier' => {context => [methods]}" do
      RateRequest::SERVICE_IDS = {
        "1" => {:carrier => "UPS", :code => "01", :service => "Ground", :context => "US Origin"},
        "2" => {:carrier => "UPS", :code => "02", :service => "Ground", :context => "Mexico Origin"},
        "3" => {:carrier => "USPS", :code => "03", :service => "Priority", :context => "Domestic"},
        "4" => {:carrier => "USPS", :code => "04", :service => "Camel", :context => "Domestic"}
      }
      expected = {
        "UPS" => {
          "Mexico Origin"=> [{:service=>"Ground", :context=>"Mexico Origin", :carrier=>"UPS", :code=>"02", :id=>"2"}],
          "US Origin"=>[{:service=>"Ground", :context=>"US Origin", :carrier=>"UPS", :code=>"01", :id=>"1"}]
        },
        "USPS"=> {
          "Domestic"=>[
            {:service=>"Camel", :context=>"Domestic", :carrier=>"USPS", :code=>"04", :id=>"4"},
            {:service=>"Priority", :context=>"Domestic", :carrier=>"USPS", :code=>"03", :id=>"3"}
          ]
        }
      }
      ShippingConsumer::ShippingHelper.methods_by_carrier_and_context.should == expected
    end
  end
end