class UpdatePromotionRuleNames < ActiveRecord::Migration[5.2]
  TYPE_RENAMES = {
    'SolidusSubscriptions::SubscriptionPromotionRule' => 'SolidusSubscriptions::Promotion::Rules::SubscriptionCreationOrder',
    'SolidusSubscriptions::SubscriptionOrderPromotionRule' => 'SolidusSubscriptions::Promotion::Rules::SubscriptionInstallmentOrder',
  }.freeze

  def change
    reversible do |dir|
      dir.up do
        TYPE_RENAMES.each do |old_type, new_type|
          Spree::PromotionRule.where(type: old_type).update(type: new_type)
        end
      end

      dir.down do
        TYPE_RENAMES.each do |old_type, new_type|
          Spree::PromotionRule.where(type: new_type).update(type: old_type)
        end
      end
    end
  end
end
