# Extend your spec with this module if you want your spec to be able to move
# an order through the checkout process
module CheckoutInfrastructure
  def self.extended(base)
    base.before(:all) do
      create :country
      create :shipping_method
    end

    base.after(:all) do
      DatabaseCleaner.clean_with(:truncation)
    end
  end
end

RSpec.configure do |config|
  config.extend CheckoutInfrastructure, :checkout
end
