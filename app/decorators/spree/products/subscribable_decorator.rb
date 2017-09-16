module Spree
  module Products
    module Subscribable
      def self.prepended(klass)
        klass.delegate :"subscribable", :"subscribable=", to: :find_or_build_master
      end
    end
  end
end

Spree::Product.prepend Spree::Products::Subscribable
