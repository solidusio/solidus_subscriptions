module Spree
  class AddressSerializer < ActiveModel::Serializer
    attributes :phone, :zipcode, :state_name, :city, :address2, :address1, :lastname, :firstname, :country_id

    has_one :country
  end
end
