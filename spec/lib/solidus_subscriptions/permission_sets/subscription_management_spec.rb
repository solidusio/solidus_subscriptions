# frozen_string_literal: true

RSpec.describe SolidusSubscriptions::PermissionSets::SubscriptionManagement do
  it 'is allowed to manage their subscriptions' do
    user = create(:user)
    subscription = create(:subscription, user: user)

    ability = Spree::Ability.new(user)
    permission_set = described_class.new(ability)
    permission_set.activate!

    expect(ability).to be_able_to(:manage, subscription)
  end

  it "is allowed to manage someone else's subscriptions" do
    user = create(:user)
    subscription = create(:subscription)

    ability = Spree::Ability.new(user)
    permission_set = described_class.new(ability)
    permission_set.activate!

    expect(ability).not_to be_able_to(:manage, subscription)
  end

  it 'is allowed to manage line items on their orders' do
    user = create(:user)
    order = create(:order, user: user)
    line_item = create(
      :subscription_line_item,
      spree_line_item: create(:line_item, order: create(:order, user: user)),
    )

    ability = Spree::Ability.new(user)
    permission_set = described_class.new(ability)
    permission_set.activate!

    expect(ability).to be_able_to(:manage, line_item, order)
  end

  it 'is allowed to manage line items on the given order' do
    user = create(:user)
    order = create(:order, user: user)
    line_item = create(
      :subscription_line_item,
      spree_line_item: create(:line_item, order: order),
    )

    ability = Spree::Ability.new(user)
    permission_set = described_class.new(ability)
    permission_set.activate!

    expect(ability).to be_able_to(:manage, line_item, order)
  end

  it "is not allowed to manage line items on someone else's orders" do
    user = create(:user)
    order = create(:order)
    line_item = create(
      :subscription_line_item,
      spree_line_item: create(:line_item),
    )

    ability = Spree::Ability.new(user)
    permission_set = described_class.new(ability)
    permission_set.activate!

    expect(ability).not_to be_able_to(:manage, line_item, order)
  end
end
