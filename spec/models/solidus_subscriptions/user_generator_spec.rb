require 'rails_helper'

RSpec.describe SolidusSubscriptions::UserGenerator do
  describe '.find_or_create' do
    subject { described_class.find_or_create(order) }

    let!(:order) { create(:order_ready_to_ship) }
    let(:order_user) { order.user }

    it { is_expected.to be_a(Spree.user_class) }
    it { is_expected.to eq(order_user) }

    context 'when user uses guest checkout' do
      let!(:order) {
        create(:order_ready_to_ship, user: nil, email: guest_email)
      }
      let(:guest_email) { 'bob@tom.com' }

      it "creates a new User record" do
        expect { subject }.to change { Spree.user_class.count }.by(1)
      end

      it 'creates a record for the guest' do
        subject
        guest_user = Spree.user_class.find_by(email: guest_email)
        expect(guest_user).to be_present
      end

      context 'and user already has an account' do
        let!(:existing_user) { create(:user, email: guest_email)}

        it { is_expected.to eq(existing_user) }
      end
    end
  end
end
