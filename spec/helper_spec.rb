require File.dirname(__FILE__) + "/spec_helper"

describe ShippingConsumer::Helper do
  describe "weight_in_lbz_oz" do
    it "should convert a weight into lbs and oz" do
      ShippingConsumer::Helper.weight_in_lbz_oz("5.6").should == [5, 10]
    end
  end
  
  describe "upcase!" do
    it "should upcase and replace _ with ' '" do
      string = "walk_this_way"
      ShippingConsumer::Helper.upcase!(string)
      string.should == "WALK THIS WAY"
    end
    
    it "should work even when it was already upcased" do
      string = "UPCASED"
      ShippingConsumer::Helper.upcase!(string)
      string.should == "UPCASED"
    end
  end
  
  describe "five_digit_zip!" do
    it "should strip down long zips to only 5 digits" do
      zip = "98105-1234"
      ShippingConsumer::Helper.five_digit_zip!(zip)
      zip.should == "98105"
    end
  end
end