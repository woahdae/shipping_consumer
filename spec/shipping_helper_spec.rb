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
  
  describe "carrier_rates_hash" do
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
      ShippingConsumer::ShippingHelper.carrier_rates_hash(rates).should == expected
    end
  end
end