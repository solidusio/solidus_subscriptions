FactoryGirl.define do
  factory :subscription, class: 'SolidusSubscriptions::Subscription' do
    user

    trait :with_line_item do
      transient do
        line_item_traits []
      end

      line_item do
        order = create(:completed_order_with_pending_payment)

        # Ensure the line item traits has an associated order
        if line_item_traits.last.is_a? Hash
          line_item_traits.last.reverse_merge!(order: order)
        else
          line_item_traits << { order: order }
        end

        build :subscription_line_item, *line_item_traits
      end
    end
  end
end
