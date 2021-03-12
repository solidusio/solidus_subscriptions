# frozen_string_literal: true

RSpec.describe SolidusSubscriptions::PermissionSets::DefaultCustomer do
  context 'when the user is authenticated' do
    it 'is allowed to display and update their subscriptions' do
      user = create(:user)
      subscription = create(:subscription, user: user)

      ability = Spree::Ability.new(user)
      permission_set = described_class.new(ability)
      permission_set.activate!

      expect(ability).to be_able_to([:show, :display, :update], subscription)
    end

    it "is not allowed to display or update someone else's subscriptions" do
      user = create(:user)
      subscription = create(:subscription)

      ability = Spree::Ability.new(user)
      permission_set = described_class.new(ability)
      permission_set.activate!

      expect(ability).not_to be_able_to([:show, :display, :update], subscription)
    end

    it 'is allowed to display and update line items on their subscriptions' do
      user = create(:user)
      subscription = create(:subscription, user: user)
      line_item = create(:subscription_line_item, subscription: subscription)

      ability = Spree::Ability.new(user)
      permission_set = described_class.new(ability)
      permission_set.activate!

      expect(ability).to be_able_to([:show, :display, :update], line_item)
    end

    it "is not allowed to display or update line items on someone else's subscriptions" do
      user = create(:user)
      subscription = create(:subscription)
      line_item = create(:subscription_line_item, subscription: subscription)

      ability = Spree::Ability.new(user)
      permission_set = described_class.new(ability)
      permission_set.activate!

      expect(ability).not_to be_able_to([:show, :display, :update], line_item)
    end
  end

  context 'when the user provides a guest token' do
    it 'is allowed to display and update their subscriptions' do
      subscription = create(:subscription)

      ability = Spree::Ability.new(nil)
      permission_set = described_class.new(ability)
      permission_set.activate!

      expect(ability).to be_able_to([:show, :display, :update], subscription, subscription.guest_token)
    end

    it "is not allowed to display or update someone else's subscriptions" do
      subscription = create(:subscription)

      ability = Spree::Ability.new(nil)
      permission_set = described_class.new(ability)
      permission_set.activate!

      expect(ability).not_to be_able_to([:show, :display, :update], subscription, 'invalid')
    end

    it 'is allowed to display and update line items on their subscriptions' do
      subscription = create(:subscription)
      line_item = create(:subscription_line_item, subscription: subscription)

      ability = Spree::Ability.new(nil)
      permission_set = described_class.new(ability)
      permission_set.activate!

      expect(ability).to be_able_to([:show, :display, :update], line_item, subscription.guest_token)
    end

    it "is not allowed to display or update line items on someone else's subscriptions" do
      subscription = create(:subscription)
      line_item = create(:subscription_line_item, subscription: subscription)

      ability = Spree::Ability.new(nil)
      permission_set = described_class.new(ability)
      permission_set.activate!

      expect(ability).not_to be_able_to([:show, :display, :update], line_item, 'invalid')
    end
  end
end
