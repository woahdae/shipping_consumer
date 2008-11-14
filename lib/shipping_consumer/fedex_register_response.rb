class FedexRegisterResponse
  include Consumer::Mapping
  attr_accessor :attribute
  
  # see documentation for full explanation.
  # Summary: map(:all or :first, "root xpath", options, &block)
  map(:all, "//FullyQualified/Xpath/ToRoot", {
      :attribute => "RelativeORFQXPathToValue",
    },
    :include => [:association1, :association2]
  ) {|instance| instance.static_attribute = "Value" }
end
