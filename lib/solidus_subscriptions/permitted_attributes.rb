# This module is responsible for managing what attributes can be updated
# through the api. It also overrides Spree::Permitted attributes to allow the
# solidus api to accept nested params for subscription models as well
module SolidusSubscriptions
  module PermittedAttributes
    class << self
      def update_spree_permiteed_attributes
        Spree::PermittedAttributes.line_item_attributes << {
          subscription_line_items_attributes: nested(
            subscription_line_item_attributes
          ),
        }

        Spree::PermittedAttributes.user_attributes << {
          subscriptions_attributes: nested(subscription_attributes),
        }
      end

      def subscription_line_item_attributes
        [Config.subscription_line_item_attributes]
      end

      def subscription_attributes
        Config.subscription_attributes | [
          { line_items_attributes: nested(subscription_line_item_attributes) - [:subscribable_id] },
        ]
      end

      private

      def nested(attributes)
        attributes | [:id]
      end
    end
  end
end
