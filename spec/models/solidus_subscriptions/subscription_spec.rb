# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSubscriptions::Subscription, type: :model do
  it { is_expected.to validate_presence_of :user }
  it { is_expected.to validate_presence_of :skip_count }
  it { is_expected.to validate_presence_of :successive_skip_count }
  it { is_expected.to validate_numericality_of(:skip_count).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:successive_skip_count).is_greater_than_or_equal_to(0) }
  it { is_expected.to accept_nested_attributes_for(:line_items) }

  it 'validates currency correctly' do
    expect(subject).to validate_inclusion_of(:currency).
      in_array(::Money::Currency.all.map(&:iso_code)).
      with_message('is not a valid currency code')
  end

  it 'validates payment_source ownership' do
    subscription = create(:subscription)

    subscription.update(payment_source: create(:credit_card))
    expect(subscription.errors.messages[:payment_source]).to include('does not belong to the user associated with the subscription')

    subscription.update(payment_source: create(:credit_card, user: subscription.user))
    expect(subscription.errors.messages[:payment_source]).not_to include('does not belong to the user associated with the subscription')
  end

  describe 'creating a subscription' do
    it 'tracks the creation' do
      stub_const('SolidusSupport::LegacyEventCompat::Bus', class_spy(SolidusSupport::LegacyEventCompat::Bus))

      subscription = create(:subscription)

      expect(SolidusSupport::LegacyEventCompat::Bus).to have_received(:publish).with(
        :'solidus_subscriptions.subscription_created',
        subscription: subscription,
      )
    end

    it 'generates a guest token' do
      subscription = create(:subscription)

      expect(subscription.guest_token).to be_present
    end

    it 'sets default config currency if not given' do
      subscription = create(:subscription, currency: nil)

      expect(subscription.currency).to eq(Spree::Config.currency)
    end
  end

  describe 'updating a subscription' do
    it 'tracks interval changes' do
      stub_const('SolidusSupport::LegacyEventCompat::Bus', class_spy(SolidusSupport::LegacyEventCompat::Bus))
      subscription = create(:subscription)

      subscription.update!(interval_length: subscription.interval_length + 1)

      expect(SolidusSupport::LegacyEventCompat::Bus).to have_received(:publish).with(
        :'solidus_subscriptions.subscription_frequency_changed',
        subscription: subscription,
      )
    end

    it 'tracks shipping address changes' do
      stub_const('SolidusSupport::LegacyEventCompat::Bus', class_spy(SolidusSupport::LegacyEventCompat::Bus))
      subscription = create(:subscription)

      subscription.update!(shipping_address: create(:address))

      expect(SolidusSupport::LegacyEventCompat::Bus).to have_received(:publish).with(
        :'solidus_subscriptions.subscription_shipping_address_changed',
        subscription: subscription,
      )
    end

    it 'tracks billing address changes' do
      stub_const('SolidusSupport::LegacyEventCompat::Bus', class_spy(SolidusSupport::LegacyEventCompat::Bus))
      subscription = create(:subscription)

      subscription.update!(billing_address: create(:address))

      expect(SolidusSupport::LegacyEventCompat::Bus).to have_received(:publish).with(
        :'solidus_subscriptions.subscription_billing_address_changed',
        subscription: subscription,
      )
    end

    it 'tracks payment method changes' do
      stub_const('SolidusSupport::LegacyEventCompat::Bus', class_spy(SolidusSupport::LegacyEventCompat::Bus))

      subscription = create(:subscription)
      subscription.update!(payment_source: create(:credit_card, user: subscription.user))

      expect(SolidusSupport::LegacyEventCompat::Bus).to have_received(:publish).with(
        :'solidus_subscriptions.subscription_payment_method_changed',
        subscription: subscription,
      )
    end
  end

  describe '#cancel' do
    subject { subscription.cancel }

    let(:subscription) do
      create :subscription, :with_line_item, actionable_date: actionable_date
    end

    around { |e| Timecop.freeze { e.run } }

    before do
      allow(SolidusSubscriptions.configuration).to receive(:minimum_cancellation_notice) { minimum_cancellation_notice }
    end

    context 'when the subscription can be canceled' do
      let(:actionable_date) { 1.month.from_now }
      let(:minimum_cancellation_notice) { 1.day }

      it 'is canceled' do
        subject
        expect(subscription).to be_canceled
      end

      it 'creates a subscription_canceled event' do
        subject
        expect(subscription.events.last).to have_attributes(event_type: 'subscription_canceled')
      end
    end

    context 'when the subscription cannot be canceled' do
      let(:actionable_date) { Date.current }
      let(:minimum_cancellation_notice) { 1.day }

      it 'is pending cancelation' do
        subject
        expect(subscription).to be_pending_cancellation
      end

      it 'creates a subscription_canceled event' do
        subject
        expect(subscription.events.last).to have_attributes(event_type: 'subscription_canceled')
      end
    end

    context 'when the minimum cancellation date is 0.days' do
      let(:actionable_date) { Date.current }
      let(:minimum_cancellation_notice) { 0.days }

      it 'is canceled' do
        subject
        expect(subscription).to be_canceled
      end
    end
  end

  describe '#pause' do
    context 'when an active subscription is paused' do
      it 'sets the paused column to true' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'active',
          paused: false
        )

        subscription.pause

        expect(subscription.reload.paused).to be_truthy
      end

      it 'does not change the state' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'active',
          paused: false
        )

        subscription.pause

        expect(subscription.reload.state).to eq('active')
      end

      it 'creates a paused event' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'active',
          paused: false
        )

        subscription.pause

        expect(subscription.events.last).to have_attributes(event_type: 'subscription_paused')
      end

      context 'when today is used as the actionable date' do
        it 'sets actionable_date to the next day' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: false
          )

          subscription.pause(actionable_date: Time.zone.today)

          expect(subscription.reload.actionable_date).to eq(Time.zone.tomorrow)
        end

        it 'is not actionable' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: false
          )

          subscription.pause(actionable_date: Time.zone.today)

          expect(described_class.actionable).not_to include subscription
        end

        it 'pauses correctly' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: false
          )

          subscription.pause(actionable_date: Time.zone.today)

          aggregate_failures do
            expect(subscription.reload.paused).to be_truthy
            expect(subscription.state).to eq('active')
          end
        end

        it 'creates a paused event' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: false
          )

          subscription.pause(actionable_date: Time.zone.today)

          expect(subscription.events.last).to have_attributes(event_type: 'subscription_paused')
        end
      end

      context 'when a past date is used as the actionable date' do
        it 'sets actionable_date to the next day' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: false
          )

          subscription.pause(actionable_date: Time.zone.yesterday)

          expect(subscription.reload.actionable_date).to eq(Time.zone.tomorrow)
        end

        it 'is not actionable' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: false
          )

          subscription.pause(actionable_date: Time.zone.yesterday)

          expect(described_class.actionable).not_to include subscription
        end

        it 'pauses correctly' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: false
          )

          subscription.pause(actionable_date: Time.zone.yesterday)

          aggregate_failures do
            expect(subscription.reload.paused).to be_truthy
            expect(subscription.state).to eq('active')
          end
        end

        it 'creates a paused event' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: false
          )

          subscription.pause(actionable_date: Time.zone.yesterday)

          expect(subscription.events.last).to have_attributes(event_type: 'subscription_paused')
        end
      end

      context 'when nil is used as the actionable date' do
        it 'sets actionable_date to nil' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: false
          )

          subscription.pause(actionable_date: nil)

          expect(subscription.reload.actionable_date).to eq(nil)
        end

        it 'is not actionable' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: false
          )

          subscription.pause(actionable_date: nil)

          expect(described_class.actionable).not_to include subscription
        end

        it 'pauses correctly' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: false
          )

          subscription.pause(actionable_date: nil)

          aggregate_failures do
            expect(subscription.reload.paused).to be_truthy
            expect(subscription.state).to eq('active')
          end
        end

        it 'creates a paused event' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: false
          )

          subscription.pause(actionable_date: nil)

          expect(subscription.events.last).to have_attributes(event_type: 'subscription_paused')
        end
      end

      context 'when a future date is used as the actionable date' do
        it 'sets actionable_date to the specified date' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: false
          )

          subscription.pause(actionable_date: (Time.zone.tomorrow + 1.day))

          expect(subscription.reload.actionable_date).to eq((Time.zone.tomorrow + 1.day))
        end

        it 'is not actionable' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: false
          )

          subscription.pause(actionable_date: (Time.zone.tomorrow + 1.day))

          expect(described_class.actionable).not_to include subscription
        end

        it 'pauses correctly' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: false
          )

          subscription.pause(actionable_date: (Time.zone.tomorrow + 1.day))

          aggregate_failures do
            expect(subscription.reload.paused).to be_truthy
            expect(subscription.state).to eq('active')
          end
        end

        it 'creates a paused event' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: false
          )

          subscription.pause(actionable_date: (Time.zone.tomorrow + 1.day))

          expect(subscription.events.last).to have_attributes(event_type: 'subscription_paused')
        end
      end

      context 'when the actionable date has been reached' do
        it 'is actionable' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: true
          )

          subscription.next_actionable_date

          expect(described_class.actionable).to include subscription
        end

        it 'processes and resumes the subscription' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: true
          )
          expected_actionable_date = subscription.actionable_date + subscription.interval

          SolidusSubscriptions::ProcessSubscriptionJob.perform_now(subscription)

          aggregate_failures do
            expect(subscription.reload.paused).to be_falsy
            expect(subscription.installments.last.created_at).to be_within(1.hour).of(Time.zone.now)
            expect(subscription.actionable_date).to eq(expected_actionable_date)
          end
        end
      end
    end

    context 'when a canceled subscription is paused' do
      it 'adds an error when the method is called on a subscription which is not active' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'canceled',
          paused: false
        )

        subscription.pause

        expect(subscription.errors[:paused].first).to include 'not active'
      end

      it 'does not alter the subscription' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'canceled',
          paused: false
        )

        expect { subscription.pause }.not_to(change { subscription.reload })
      end

      it 'does not create an event' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'canceled',
          paused: false
        )

        subscription.pause

        expect(subscription.events.last).not_to have_attributes(event_type: "subscription_paused")
      end
    end

    context 'when a `pending_cancellation` subscription is paused' do
      it 'adds an error when the method is called on a subscription which is not active' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'pending_cancellation',
          paused: false
        )

        subscription.pause

        expect(subscription.errors[:paused].first).to include 'not active'
      end

      it 'does not alter the subscription' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'pending_cancellation',
          paused: false
        )

        expect { subscription.pause }.not_to(change { subscription.reload })
      end

      it 'does not create an event' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'pending_cancellation',
          paused: true
        )

        subscription.pause

        expect(subscription.events.last).not_to have_attributes(event_type: "subscription_paused")
      end
    end

    context 'when an `inactive` subscription is paused' do
      it 'adds an error when the method is called on a subscription which is not active' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'inactive',
          paused: false
        )

        subscription.pause

        expect(subscription.errors[:paused].first).to include 'not active'
      end

      it 'does not alter the subscription' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'inactive',
          paused: false
        )

        expect { subscription.pause }.not_to(change { subscription.reload })
      end

      it 'does not create an event' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'inactive',
          paused: false
        )

        subscription.pause

        expect(subscription.events.last).not_to have_attributes(event_type: "subscription_paused")
      end
    end
  end

  describe '#resume' do
    context 'when an active subscription is resumed' do
      it 'sets the paused column to false' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'active',
          paused: true
        )

        subscription.resume

        expect(subscription.reload.paused).to be_falsy
      end

      it 'does not change the state' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'active',
          paused: true
        )

        subscription.resume

        expect(subscription.reload.state).to eq('active')
      end

      it 'creates a resumed event' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'active',
          paused: true
        )

        subscription.resume

        expect(subscription.events.last).to have_attributes(event_type: 'subscription_resumed')
      end

      context 'when a past date is used as the actionable date' do
        it 'sets actionable_date to the next day' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: true
          )

          subscription.resume(actionable_date: Time.zone.yesterday)

          expect(subscription.reload.actionable_date).to eq(Time.zone.tomorrow)
        end

        it 'is not actionable' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: true
          )

          subscription.resume(actionable_date: Time.zone.yesterday)

          expect(described_class.actionable).not_to include subscription
        end

        it 'resumes correctly' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: true
          )

          subscription.resume(actionable_date: Time.zone.yesterday)

          aggregate_failures do
            expect(subscription.reload.paused).to be_falsy
            expect(subscription.state).to eq('active')
          end
        end

        it 'creates a resumed event' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: true
          )

          subscription.resume(actionable_date: Time.zone.yesterday)

          expect(subscription.events.last).to have_attributes(event_type: 'subscription_resumed')
        end
      end

      context 'when today is used as the actionable date' do
        it 'sets actionable_date to the next day' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: true
          )

          subscription.resume(actionable_date: Time.zone.today)

          expect(subscription.reload.actionable_date).to eq(Time.zone.tomorrow)
        end

        it 'is not actionable' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: true
          )

          subscription.resume(actionable_date: Time.zone.today)

          expect(described_class.actionable).not_to include subscription
        end

        it 'resumes correctly' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: true
          )

          subscription.resume(actionable_date: Time.zone.today)

          aggregate_failures do
            expect(subscription.reload.paused).to be_falsy
            expect(subscription.state).to eq('active')
          end
        end

        it 'creates a resumed event' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: true
          )

          subscription.resume(actionable_date: Time.zone.today)

          expect(subscription.events.last).to have_attributes(event_type: 'subscription_resumed')
        end
      end

      context 'when nil is used as the actionable date' do
        it 'sets actionable_date to the next day' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: true
          )

          subscription.resume(actionable_date: nil)

          expect(subscription.reload.actionable_date).to eq(Time.zone.tomorrow)
        end

        it 'is not actionable' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: true
          )

          subscription.resume(actionable_date: nil)

          expect(described_class.actionable).not_to include subscription
        end

        it 'resumes correctly' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: true
          )

          subscription.resume(actionable_date: nil)

          aggregate_failures do
            expect(subscription.reload.paused).to be_falsy
            expect(subscription.state).to eq('active')
          end
        end

        it 'creates a resumed event' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: true
          )

          subscription.resume(actionable_date: nil)

          expect(subscription.events.last).to have_attributes(event_type: 'subscription_resumed')
        end
      end

      context 'when a future date is used as the actionable date' do
        it 'sets actionable_date to the specified date' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: true
          )

          subscription.resume(actionable_date: (Time.zone.tomorrow + 1.day))

          expect(subscription.reload.actionable_date).to eq((Time.zone.tomorrow + 1.day))
        end

        it 'is not actionable' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: true
          )

          subscription.resume(actionable_date: (Time.zone.tomorrow + 1.day))

          expect(described_class.actionable).not_to include subscription
        end

        it 'resumes correctly' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: true
          )

          subscription.resume(actionable_date: (Time.zone.tomorrow + 1.day))

          aggregate_failures do
            expect(subscription.reload.paused).to be_falsy
            expect(subscription.state).to eq('active')
          end
        end

        it 'creates a resumed event' do
          subscription = create(
            :subscription,
            :actionable,
            :with_shipping_address,
            state: 'active',
            paused: true
          )

          subscription.resume(actionable_date: (Time.zone.tomorrow + 1.day))

          expect(subscription.events.last).to have_attributes(event_type: 'subscription_resumed')
        end
      end
    end

    context 'when a `canceled` subscription is resumed' do
      it 'does not alter the subscription' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'canceled',
          paused: true
        )

        expect { subscription.resume }.not_to(change { subscription.reload })
      end

      it 'does not create an event' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'canceled',
          paused: true
        )

        subscription.resume

        expect(subscription.events.last).not_to have_attributes(event_type: "subscription_resumed")
      end
    end

    context 'when a `pending_cancellation` subscription is resumed' do
      it 'does not alter the subscription' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'pending_cancellation',
          paused: true
        )

        expect { subscription.resume }.not_to(change { subscription.reload })
      end

      it 'does not create an event' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'pending_cancellation',
          paused: true
        )

        subscription.resume

        expect(subscription.events.last).not_to have_attributes(event_type: "subscription_resumed")
      end
    end

    context 'when an `inactive` subscription is resumed' do
      it 'does not alter the subscription' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'inactive',
          paused: true
        )

        expect { subscription.resume }.not_to(change { subscription.reload })
      end

      it 'does not create an event' do
        subscription = create(
          :subscription,
          :actionable,
          :with_shipping_address,
          state: 'inactive',
          paused: true
        )

        subscription.resume

        expect(subscription.events.last).not_to have_attributes(event_type: "subscription_resumed")
      end
    end
  end

  describe '#state_with_pause' do
    it 'returns `paused` when the subscription is active and paused' do
      subscription = create(
        :subscription,
        :with_shipping_address,
        paused: true,
        state: 'active'
      )

      expect(subscription.state_with_pause).to eq('paused')
    end

    it 'returns `active` when the subscription is active and not paused' do
      subscription = create(
        :subscription,
        :with_shipping_address,
        paused: false,
        state: 'active'
      )

      expect(subscription.state_with_pause).to eq('active')
    end

    it 'returns `canceled` when the subscription is canceled and not paused' do
      subscription = create(
        :subscription,
        :with_shipping_address,
        paused: false,
        state: 'canceled'
      )

      expect(subscription.state_with_pause).to eq('canceled')
    end
  end

  describe '#skip' do
    subject { subscription.skip&.to_date }

    let(:total_skips) { 0 }
    let(:successive_skips) { 0 }
    let(:expected_date) { 2.months.from_now.to_date }

    let(:subscription) do
      create(
        :subscription,
        :with_line_item,
        skip_count: total_skips,
        successive_skip_count: successive_skips
      )
    end

    before { stub_config(maximum_total_skips: 1) }

    context 'when the successive skips have been exceeded' do
      let(:successive_skips) { 1 }

      it { is_expected.to be_falsy }

      it 'adds errors to the subscription' do
        subject
        expect(subscription.errors[:successive_skip_count]).not_to be_empty
      end

      it 'does not create an event' do
        expect { subject }.not_to change(subscription.events, :count)
      end
    end

    context 'when the total skips have been exceeded' do
      let(:total_skips) { 1 }

      it { is_expected.to be_falsy }

      it 'adds errors to the subscription' do
        subject
        expect(subscription.errors[:skip_count]).not_to be_empty
      end

      it 'does not create an event' do
        expect { subject }.not_to change(subscription.events, :count)
      end
    end

    context 'when the subscription can be skipped' do
      it { is_expected.to eq expected_date }

      it 'creates a subscription_skipped event' do
        subject
        expect(subscription.events.last).to have_attributes(event_type: 'subscription_skipped')
      end
    end
  end

  describe '#deactivate' do
    subject { subscription.deactivate }

    let(:attributes) { {} }
    let(:subscription) do
      create :subscription, :actionable, :with_line_item, attributes do |s|
        s.installments = build_list(:installment, 2)
      end
    end

    context 'when the subscription can be deactivated' do
      let(:attributes) do
        { end_date: Date.current.ago(2.days) }
      end

      it 'is inactive' do
        subject
        expect(subscription).to be_inactive
      end

      it 'creates a subscription_deactivated event' do
        subject
        expect(subscription.events.last).to have_attributes(event_type: 'subscription_ended')
      end
    end

    context 'when the subscription cannot be deactivated' do
      it { is_expected.to be_falsy }

      it 'does not create an event' do
        expect { subject }.not_to change(subscription.events, :count)
      end
    end
  end

  describe '#activate' do
    context 'when the subscription can be activated' do
      it 'activates the subscription' do
        subscription = create(:subscription,
          actionable_date: Time.zone.today,
          end_date: Time.zone.yesterday,)
        subscription.deactivate!

        subscription.activate

        expect(subscription.state).to eq('active')
      end

      it 'creates a subscription_activated event' do
        subscription = create(:subscription,
          actionable_date: Time.zone.today,
          end_date: Time.zone.yesterday,)
        subscription.deactivate!

        subscription.activate

        expect(subscription.events.last).to have_attributes(event_type: 'subscription_activated')
      end
    end

    context 'when the subscription cannot be activated' do
      it 'returns false' do
        subscription = create(:subscription, actionable_date: Time.zone.today)

        expect(subscription.activate).to eq(false)
      end

      it 'does not create an event' do
        subscription = create(:subscription, actionable_date: Time.zone.today)

        expect {
          subscription.activate
        }.not_to change(subscription.events, :count)
      end
    end
  end

  describe '#next_actionable_date' do
    subject { subscription.next_actionable_date }

    context "when the subscription is active" do
      let(:expected_date) { Date.current + subscription.interval }
      let(:subscription) do
        build_stubbed(
          :subscription,
          :with_line_item,
          actionable_date: Date.current
        )
      end

      it { is_expected.to eq expected_date }
    end

    context "when the subscription is not active" do
      let(:subscription) { build_stubbed :subscription, :with_line_item, state: :canceled }

      it { is_expected.to be_nil }
    end
  end

  describe '#advance_actionable_date' do
    subject { subscription.advance_actionable_date }

    let(:expected_date) { Date.current + subscription.interval }
    let(:subscription) do
      build(
        :subscription,
        :with_line_item,
        actionable_date: Date.current
      )
    end

    it { is_expected.to eq expected_date }

    it 'updates the subscription with the new actionable date' do
      subject
      expect(subscription.reload).to have_attributes(
        actionable_date: expected_date
      )
    end
  end

  describe ".actionable" do
    subject { described_class.actionable }

    let!(:past_subscription) { create :subscription, actionable_date: 2.days.ago }
    let!(:future_subscription) { create :subscription, actionable_date: 1.month.from_now }
    let!(:inactive_subscription) { create :subscription, state: "inactive", actionable_date: 7.days.ago }
    let!(:canceled_subscription) { create :subscription, state: "canceled", actionable_date: 4.days.ago }

    it "returns subscriptions that have an actionable date in the past" do
      expect(subject).to include past_subscription
    end

    it "does not include future subscriptions" do
      expect(subject).not_to include future_subscription
    end

    it "does not include inactive subscriptions" do
      expect(subject).not_to include inactive_subscription
    end

    it "does not include canceled subscriptions" do
      expect(subject).not_to include canceled_subscription
    end
  end

  describe '#processing_state' do
    subject { subscription.processing_state }

    context 'when the subscription has never been processed' do
      let(:subscription) { build_stubbed :subscription }

      it { is_expected.to eq 'pending' }
    end

    context 'when the last processing attempt failed' do
      let(:subscription) do
        create(
          :subscription,
          installments: create_list(:installment, 1, :failed)
        )
      end

      it { is_expected.to eq 'failed' }
    end

    context 'when the last processing attempt succeeded' do
      let(:order) { create :completed_order_with_totals }

      let(:subscription) do
        create(
          :subscription,
          installments: create_list(
            :installment,
            1,
            :success,
            details: build_list(:installment_detail, 1, order: order, success: true)
          )
        )
      end

      it { is_expected.to eq 'success' }
    end
  end

  describe '.ransackable_scopes' do
    subject { described_class.ransackable_scopes }

    it { is_expected.to match_array [:in_processing_state, :with_line_item] }
  end

  describe '.with_line_item' do
    let(:subscription) do
      create :subscription, :with_line_item
    end

    it 'can find subscription with line item' do
      line_item_id = subscription.line_items.first.id
      found_subscription = ::SolidusSubscriptions::Subscription.with_line_item(line_item_id).first

      expect(found_subscription.id).to eql(subscription.id)
    end
  end

  describe '.in_processing_state' do
    subject { described_class.in_processing_state(state) }

    let!(:new_subs) { create_list :subscription, 2 }
    let!(:failed_subs) { create_list(:installment, 2, :failed).map(&:subscription) }
    let!(:success_subs) { create_list(:installment, 2, :success).map(&:subscription) }

    context 'with successfull subscriptions' do
      let(:state) { :success }

      it { is_expected.to match_array success_subs }
    end

    context 'with failed subscriptions' do
      let(:state) { :failed }

      it { is_expected.to match_array failed_subs }
    end

    context 'with new subscriptions' do
      let(:state) { :pending }

      it { is_expected.to match_array new_subs }
    end

    context 'with unknown state' do
      let(:state) { :foo }

      it 'raises an error' do
        expect { subject }.to raise_error ArgumentError, /state must be one of/
      end
    end
  end

  describe '.processing_states' do
    subject { described_class.processing_states }

    it { is_expected.to match_array [:pending, :success, :failed] }
  end

  describe '#payment_source_to_use' do
    context 'when the subscription has a payment method without source' do
      it 'returns nil' do
        payment_method = create(:check_payment_method)

        subscription = create(:subscription, payment_method: payment_method)

        expect(subscription.payment_source_to_use).to eq(nil)
      end
    end

    context 'when the subscription has a payment method with a source' do
      it 'returns the source on the subscription' do
        user = create(:user)
        payment_method = create(:credit_card_payment_method)
        payment_source = create(:credit_card,
          payment_method: payment_method,
          gateway_customer_profile_id: 'BGS-123',
          user: user,)

        subscription = create(:subscription,
          user: user,
          payment_method: payment_method,
          payment_source: payment_source,)

        expect(subscription.payment_source_to_use).to eq(payment_source)
      end
    end

    context 'when the subscription has no payment method' do
      it "returns the default source from the user's wallet_payment_source" do
        user = create(:user)
        payment_source = create(:credit_card, gateway_customer_profile_id: 'BGS-123', user: user)
        wallet_payment_source = user.wallet.add(payment_source)
        user.wallet.default_wallet_payment_source = wallet_payment_source

        subscription = create(:subscription, user: user)

        expect(subscription.payment_source_to_use).to eq(payment_source)
      end
    end
  end

  describe '#payment_method_to_use' do
    context 'when the subscription has a payment method without source' do
      it 'returns the payment method on the subscription' do
        payment_method = create(:check_payment_method)
        subscription = create(:subscription, payment_method: payment_method)

        expect(subscription.payment_method_to_use).to eq(payment_method)
      end
    end

    context 'when the subscription has a payment method with a source' do
      it 'returns the payment method on the subscription' do
        user = create(:user)
        payment_method = create(:credit_card_payment_method)
        payment_source = create(:credit_card,
          payment_method: payment_method,
          gateway_customer_profile_id: 'BGS-123',
          user: user,)

        subscription = create(:subscription,
          user: user,
          payment_method: payment_method,
          payment_source: payment_source,)

        expect(subscription.payment_method_to_use).to eq(payment_method)
      end
    end

    context 'when the subscription has no payment method' do
      it "returns the method from the default source in the user's wallet_payment_source" do
        user = create(:user)
        payment_source = create(:credit_card, gateway_customer_profile_id: 'BGS-123', user: user)
        wallet_payment_source = user.wallet.add(payment_source)
        user.wallet.default_wallet_payment_source = wallet_payment_source

        subscription = create(:subscription, user: user)

        expect(subscription.payment_method_to_use).to eq(payment_source.payment_method)
      end
    end
  end

  describe '#billing_address_to_use' do
    context 'when the subscription has a billing address' do
      it 'returns the billing address on the subscription' do
        billing_address = create(:bill_address)

        subscription = create(:subscription, billing_address: billing_address)

        expect(subscription.billing_address_to_use).to eq(billing_address)
      end
    end

    context 'when the subscription has no billing address' do
      it 'returns the billing address on the user' do
        user = create(:user)
        billing_address = create(:bill_address)
        user.bill_address = billing_address

        subscription = create(:subscription, user: user)

        expect(subscription.billing_address_to_use).to eq(billing_address)
      end
    end
  end

  describe '#shipping_address_to_use' do
    context 'when the subscription has a shipping address' do
      it 'returns the shipping address on the subscription' do
        shipping_address = create(:ship_address)

        subscription = create(:subscription, shipping_address: shipping_address)

        expect(subscription.shipping_address_to_use).to eq(shipping_address)
      end
    end

    context 'when the subscription has no shipping address' do
      it 'returns the shipping address on the user' do
        user = create(:user)
        shipping_address = create(:ship_address)
        user.ship_address = shipping_address

        subscription = create(:subscription, user: user)

        expect(subscription.shipping_address_to_use).to eq(shipping_address)
      end
    end
  end

  describe "#update_actionable_date_if_interval_changed" do
    context "with installments" do
      context "when the last installment date would cause the interval to be in the past" do
        it "sets the actionable_date to the current day" do
          subscription = create(:subscription, actionable_date: Time.zone.parse('2016-08-22'))
          create(:installment, subscription: subscription, created_at: Time.zone.parse('2016-07-22'))

          subscription.update!(interval_length: 1, interval_units: 'month')

          expect(subscription.actionable_date).to eq(Time.zone.today)
        end
      end

      context "when the last installment date would cause the interval to be in the future" do
        it "sets the actionable_date to an interval from the last installment" do
          subscription = create(:subscription, actionable_date: Time.zone.parse('2016-08-22'))
          create(:installment, subscription: subscription, created_at: 4.days.ago)

          subscription.update!(interval_length: 1, interval_units: 'month')

          expect(subscription.actionable_date).to eq((4.days.ago + 1.month).to_date)
        end
      end
    end

    context "when there are no installments" do
      context "when the subscription creation date would cause the interval to be in the past" do
        it "sets the actionable_date to the current day" do
          subscription = create(:subscription, created_at: Time.zone.parse('2016-08-22'))

          subscription.update!(interval_length: 1, interval_units: 'month')

          expect(subscription.actionable_date).to eq(Time.zone.today)
        end
      end

      context "when the subscription creation date would cause the interval to be in the future" do
        it "sets the actionable_date to one interval past the subscription creation date" do
          subscription = create(:subscription, created_at: 4.days.ago)

          subscription.update!(interval_length: 1, interval_units: 'month')

          expect(subscription.actionable_date).to eq((4.days.ago + 1.month).to_date)
        end
      end
    end
  end

  describe '#failing_since' do
    context 'when the subscription is not failing' do
      it 'returns nil' do
        subscription = create(:subscription, installments: [
          create(:installment, details: [
            create(:installment_detail, success: false, created_at: '2020-11-11'),
            create(:installment_detail, success: false, created_at: '2020-11-12'),
            create(:installment_detail, success: true, created_at: '2020-11-13'),
          ]),
          create(:installment, details: [
            create(:installment_detail, success: false, created_at: '2020-11-24'),
            create(:installment_detail, success: true, created_at: '2020-11-25'),
          ]),
        ])

        expect(subscription.failing_since).to eq(nil)
      end
    end

    context 'when the subscription is failing with a previous success' do
      it 'returns the date of the first failure' do
        subscription = create(:subscription, installments: [
          create(:installment, details: [
            create(:installment_detail, success: false, created_at: '2020-11-11'),
            create(:installment_detail, success: false, created_at: '2020-11-12'),
            create(:installment_detail, success: true, created_at: '2020-11-13'),
          ]),
          create(:installment, details: [
            create(:installment_detail, success: false, created_at: '2020-11-24'),
            create(:installment_detail, success: false, created_at: '2020-11-25'),
          ]),
          create(:installment, details: [
            create(:installment_detail, success: false, created_at: '2020-11-26'),
            create(:installment_detail, success: false, created_at: '2020-11-27'),
          ]),
        ])

        expect(subscription.failing_since).to eq(Time.zone.parse('2020-11-24'))
      end
    end

    context 'when the subscription is failing with no previous success' do
      it 'returns the date of the first failure' do
        subscription = create(:subscription, installments: [
          create(:installment, details: [
            create(:installment_detail, success: false, created_at: '2020-11-11'),
            create(:installment_detail, success: false, created_at: '2020-11-12'),
            create(:installment_detail, success: false, created_at: '2020-11-13'),
          ]),
          create(:installment, details: [
            create(:installment_detail, success: false, created_at: '2020-11-24'),
            create(:installment_detail, success: false, created_at: '2020-11-25'),
          ]),
          create(:installment, details: [
            create(:installment_detail, success: false, created_at: '2020-11-26'),
            create(:installment_detail, success: false, created_at: '2020-11-27'),
          ]),
        ])

        expect(subscription.failing_since).to eq(Time.zone.parse('2020-11-11'))
      end
    end
  end

  describe '#maximum_reprocessing_time_reached?' do
    context 'when maximum_reprocessing_time is not configured' do
      it 'returns false' do
        stub_config(maximum_reprocessing_time: 5.days)
        subscription = create(:subscription)

        expect(subscription.maximum_reprocessing_time_reached?).to eq(false)
      end
    end

    context 'when maximum_reprocessing_time is configured' do
      context 'when the subscription has been failing for too long' do
        it 'returns true' do
          stub_config(maximum_reprocessing_time: 15.days)

          subscription = create(:subscription, installments: [
            create(:installment, details: [
              create(:installment_detail, success: false, created_at: 20.days.ago),
              create(:installment_detail, success: false, created_at: 19.days.ago),
              create(:installment_detail, success: true, created_at: 18.days.ago),
            ]),
            create(:installment, details: [
              create(:installment_detail, success: false, created_at: 17.days.ago),
              create(:installment_detail, success: false, created_at: 16.days.ago),
            ]),
            create(:installment, details: [
              create(:installment_detail, success: false, created_at: 15.days.ago),
              create(:installment_detail, success: false, created_at: 14.days.ago),
            ]),
          ])

          expect(subscription.maximum_reprocessing_time_reached?).to eq(true)
        end
      end

      context 'when the subscription has not been failing for too long' do
        it 'returns false' do
          stub_config(maximum_reprocessing_time: 15.days)

          subscription = create(:subscription, installments: [
            create(:installment, details: [
              create(:installment_detail, success: false, created_at: 15.days.ago),
              create(:installment_detail, success: false, created_at: 14.days.ago),
              create(:installment_detail, success: true, created_at: 13.days.ago),
            ]),
            create(:installment, details: [
              create(:installment_detail, success: false, created_at: 12.days.ago),
              create(:installment_detail, success: false, created_at: 11.days.ago),
            ]),
            create(:installment, details: [
              create(:installment_detail, success: false, created_at: 10.days.ago),
              create(:installment_detail, success: false, created_at: 9.days.ago),
            ]),
          ])

          expect(subscription.maximum_reprocessing_time_reached?).to eq(false)
        end
      end

      context 'when the subscription is not failing' do
        it 'returns false' do
          stub_config(maximum_reprocessing_time: 2.days)

          subscription = create(:subscription, installments: [
            create(:installment, details: [
              create(:installment_detail, success: false, created_at: 15.days.ago),
              create(:installment_detail, success: false, created_at: 14.days.ago),
              create(:installment_detail, success: true, created_at: 13.days.ago),
            ]),
            create(:installment, details: [
              create(:installment_detail, success: false, created_at: 12.days.ago),
              create(:installment_detail, success: false, created_at: 11.days.ago),
            ]),
            create(:installment, details: [
              create(:installment_detail, success: false, created_at: 10.days.ago),
              create(:installment_detail, success: true, created_at: 9.days.ago),
            ]),
          ])

          expect(subscription.maximum_reprocessing_time_reached?).to eq(false)
        end
      end
    end
  end

  describe '#actionable?' do
    context 'when the actionable date is nil' do
      it 'is not actionable' do
        subscription = build_stubbed(:subscription, actionable_date: nil)

        expect(subscription).not_to be_actionable
      end
    end

    context 'when the actionable date is in the future' do
      it 'is not actionable' do
        subscription = build_stubbed(:subscription, actionable_date: Time.zone.today + 5.days)

        expect(subscription).not_to be_actionable
      end
    end

    context 'when the state is either canceled or inactive' do
      it 'is not actionable' do
        canceled_subscription = build_stubbed(:subscription, :canceled)
        inactive_subscription = build_stubbed(:subscription, :inactive)

        [canceled_subscription, inactive_subscription].each do |subscription|
          expect(subscription).not_to be_actionable
        end
      end
    end

    context 'when the active subscription actionable date is today or in the past' do
      it 'is actionable' do
        subscription = build_stubbed(:subscription, actionable_date: Time.zone.today)

        expect(subscription).to be_actionable
      end
    end
  end
end
