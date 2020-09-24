# frozen_string_literal: true

# This module is responsible for managing what attributes can be updated
# through the api. It also overrides Spree::Permitted attributes to allow the
# solidus api to accept nested params for subscription models as well
module SolidusSubscriptions
  module PermittedAttributes
    class << self
      def subscription_line_item_attributes
        [SolidusSubscriptions.configuration.subscription_line_item_attributes]
      end

      def subscription_attributes
        SolidusSubscriptions.configuration.subscription_attributes | [
          line_items_attributes: (subscription_line_item_attributes | [:id] - [:subscribable_id]),
        ]
      end
    end
  end
end
