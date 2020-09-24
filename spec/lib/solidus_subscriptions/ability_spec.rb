require 'spec_helper'
require "cancan/matchers"

RSpec.describe SolidusSubscriptions::Ability do
  subject { described_class.new user }

  context 'when the user is a default customer' do
    let(:user) { create :user }

    context 'owns the order' do
      let(:order) { create :order }
      let(:line_item) do
        create :subscription_line_item, order: order
      end

      it { is_expected.to be_able_to :index, line_item, order }
      it { is_expected.to be_able_to :show, line_item, order }
      it { is_expected.to be_able_to :create, line_item, order }
      it { is_expected.to be_able_to :update, line_item, order }
      it { is_expected.to be_able_to :destroy, line_item, order }
    end

    context 'doesnt own the order' do
      let(:order) { create :order }
      let(:another_order) { create :order }

      let(:line_item) do
        create :subscription_line_item, order: order
      end

      it { is_expected.not_to be_able_to :index, line_item, another_order }
      it { is_expected.not_to be_able_to :show, line_item, another_order }
      it { is_expected.not_to be_able_to :create, line_item, another_order }
      it { is_expected.not_to be_able_to :update, line_item, another_order }
      it { is_expected.not_to be_able_to :destroy, line_item, another_order }
    end

    context 'the user owns a subscription' do
      let(:subscription) { create :subscription, user: user }

      it { is_expected.to be_able_to :index, subscription }
      it { is_expected.to be_able_to :show, subscription }
      it { is_expected.to be_able_to :create, subscription }
      it { is_expected.to be_able_to :update, subscription }
      it { is_expected.to be_able_to :destroy, subscription }
      it { is_expected.to be_able_to :skip, subscription }
      it { is_expected.to be_able_to :cancel, subscription }
    end

    context 'the doesnt own a subscription' do
      let(:another_user) { create :user }
      let(:subscription) { create :subscription, user: another_user }

      it { is_expected.not_to be_able_to :index, subscription }
      it { is_expected.not_to be_able_to :show, subscription }
      it { is_expected.not_to be_able_to :create, subscription }
      it { is_expected.not_to be_able_to :update, subscription }
      it { is_expected.not_to be_able_to :destroy, subscription }
      it { is_expected.not_to be_able_to :skip, subscription }
      it { is_expected.not_to be_able_to :cancel, subscription }
    end
  end

  context 'the user is an admin' do
    let(:user) { create :admin_user }

    it { is_expected.to be_able_to :manage, SolidusSubscriptions::Subscription }
    it { is_expected.to be_able_to :manage, SolidusSubscriptions::LineItem }
  end
end
