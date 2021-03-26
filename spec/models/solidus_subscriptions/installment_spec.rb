# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSubscriptions::Installment, type: :model do
  let(:installment) { create :installment }

  it { is_expected.to validate_presence_of :subscription }

  describe '#out_of_stock' do
    subject(:out_of_stock) { installment.out_of_stock }

    let(:expected_date) do
      Time.zone.today + SolidusSubscriptions.configuration.reprocessing_interval
    end

    it { is_expected.to be_a SolidusSubscriptions::InstallmentDetail }
    it { is_expected.not_to be_successful }

    it 'has the correct message' do
      expect(out_of_stock).to have_attributes(
        message: I18n.t('solidus_subscriptions.installment_details.out_of_stock')
      )
    end

    it 'advances the installment actionable_date' do
      out_of_stock
      actionable_date = installment.reload.actionable_date
      expect(actionable_date).to eq expected_date
    end
  end

  describe '#success!' do
    subject(:success) { installment.success!(order) }

    let(:order) { create :order }

    let(:installment) { create :installment, actionable_date: actionable_date }
    let(:actionable_date) { 1.month.from_now.to_date }

    it 'removes any actionable date if any' do
      expect { success }.
        to change(installment, :actionable_date).
        from(actionable_date).to(nil)
    end

    it 'creates a new installment detail' do
      expect { success }.
        to change { SolidusSubscriptions::InstallmentDetail.count }.
        by(1)
    end

    it 'creates a successful installment detail' do
      success
      expect(installment.details.last).to be_successful && have_attributes(
        order: order,
        message: I18n.t('solidus_subscriptions.installment_details.success')
      )
    end
  end

  describe '#failed!' do
    subject(:failed) { installment.failed!(order) }

    let(:order) { create :order }

    let(:expected_date) do
      Time.zone.today + SolidusSubscriptions.configuration.reprocessing_interval
    end

    it { is_expected.to be_a SolidusSubscriptions::InstallmentDetail }
    it { is_expected.not_to be_successful }

    it 'has the correct message' do
      expect(failed).to have_attributes(
        message: I18n.t('solidus_subscriptions.installment_details.failed'),
        order: order
      )
    end

    it 'advances the installment actionable_date' do
      failed
      actionable_date = installment.reload.actionable_date
      expect(actionable_date).to eq expected_date
    end

    context 'when the reprocessing interval is set to nil' do
      before { stub_config(reprocessing_interval: nil) }

      it 'does not advance the installment actionable_date' do
        failed
        actionable_date = installment.reload.actionable_date
        expect(actionable_date).to be_nil
      end
    end
  end

  describe '#unfulfilled?' do
    subject { installment.unfulfilled? }

    let(:installment) { create(:installment, details: details) }

    context 'when the installment has an associated successful detail' do
      let(:details) { create_list :installment_detail, 1, success: true }

      it { is_expected.to be_falsy }
    end

    context 'when the installment has no associated successful detail' do
      let(:details) { create_list :installment_detail, 1 }

      it { is_expected.to be_truthy }
    end
  end

  describe '#fulfilled' do
    subject { installment.fulfilled? }

    let(:installment) { create(:installment, details: details) }

    context 'when the installment has an associated completed order' do
      let(:details) { create_list :installment_detail, 1, success: true }

      it { is_expected.to be_truthy }
    end

    context 'when the installment has no associated completed order' do
      let(:details) { create_list :installment_detail, 1 }

      it { is_expected.to be_falsy }
    end
  end

  describe '#payment_failed!' do
    context 'when the maximum reprocessing time has been reached' do
      it 'creates a new installment detail' do
        subscription = create(:subscription)
        allow(subscription).to receive(:maximum_reprocessing_time_reached?).and_return(true)

        current_installment = create(:installment, subscription: subscription)
        current_installment.payment_failed!(create(:order))

        expect(current_installment.details.count).to eq(1)
      end

      it 'sets the actionable_date to nil' do
        subscription = create(:subscription)
        allow(subscription).to receive(:maximum_reprocessing_time_reached?).and_return(true)

        current_installment = create(:installment, subscription: subscription)
        current_installment.payment_failed!(create(:order))

        expect(current_installment.actionable_date).to eq(nil)
      end

      it 'cancels the subscription' do
        subscription = create(:subscription)
        allow(subscription).to receive(:maximum_reprocessing_time_reached?).and_return(true)

        current_installment = create(:installment, subscription: subscription)
        current_installment.payment_failed!(create(:order))

        expect(current_installment.subscription.state).to eq('canceled')
      end
    end

    context 'when the maximum reprocessing time has not been reached' do
      it 'creates a new installment detail' do
        subscription = create(:subscription)
        allow(subscription).to receive(:maximum_reprocessing_time_reached?).and_return(false)

        current_installment = create(:installment, subscription: subscription)
        current_installment.payment_failed!(create(:order))
        current_installment.payment_failed!(create(:order))

        expect(current_installment.details.count).to eq(2)
      end

      it "advances the installment's actionable_date" do
        subscription = create(:subscription)
        allow(subscription).to receive(:maximum_reprocessing_time_reached?).and_return(false)
        stub_config(reprocessing_interval: 2.days)

        current_installment = create(:installment, subscription: subscription)
        current_installment.payment_failed!(create(:order))

        expect(current_installment.actionable_date).to eq(Time.zone.today + 2.days)
      end

      it 'does not cancel the subscription' do
        subscription = create(:subscription)
        allow(subscription).to receive(:maximum_reprocessing_time_reached?).and_return(false)

        current_installment = create(:installment, subscription: subscription)
        current_installment.payment_failed!(create(:order))

        expect(subscription.state).to eq('active')
      end
    end
  end
end
