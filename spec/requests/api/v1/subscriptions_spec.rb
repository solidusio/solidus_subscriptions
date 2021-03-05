# frozen_string_literal: true

RSpec.describe '/api/v1/subscriptions' do
  include SolidusSubscriptions::Engine.routes.url_helpers

  describe 'POST /' do
    context 'with valid params' do
      it 'creates the subscription and responds with 200 OK' do
        user = create(:user, &:generate_spree_api_key!)

        expect do
          post(
            api_v1_subscriptions_path,
            params: { subscription: { interval_length: 11 } },
            headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
          )
        end.to change(SolidusSubscriptions::Subscription, :count).from(0).to(1)

        expect(response.status).to eq(200)
      end
    end

    context 'with invalid params' do
      it "doesn't create the subscription and responds with 422 Unprocessable Entity" do
        user = create(:user, &:generate_spree_api_key!)

        expect do
          post(
            api_v1_subscriptions_path,
            params: { subscription: { interval_length: -1 } },
            headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
          )
        end.not_to change(SolidusSubscriptions::Subscription, :count)

        expect(response.status).to eq(422)
      end
    end

    context 'when valid payment attributes are provided' do
      # rubocop:disable RSpec/MultipleExpectations
      it 'creates the subscription using the specified payment' do
        user = create(:user, &:generate_spree_api_key!)
        payment_source = create(:credit_card, user: user)
        payment_params = { payment_method_id: payment_source.payment_method.id, payment_source_id: payment_source.id }

        expect(user.wallet.default_wallet_payment_source).to be_nil
        expect do
          post(
            api_v1_subscriptions_path,
            params: { subscription: { interval_length: 7 }.merge(payment_params) },
            headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
          )
        end.to change(SolidusSubscriptions::Subscription, :count).from(0).to(1)
        expect(SolidusSubscriptions::Subscription.last).to have_attributes(payment_params)
      end
      # rubocop:enable RSpec/MultipleExpectations
    end

    # rubocop:disable RSpec/MultipleExpectations
    context 'when an invalid payment method is provided' do
      it "doesn't create the subscription and responds with 422 Unprocessable Entity" do
        user = create(:user, &:generate_spree_api_key!)
        payment_source = create(:credit_card)
        payment_params = { payment_source_id: payment_source.id }

        expect do
          post(
            api_v1_subscriptions_path,
            params: { subscription: { interval_length: 7 }.merge(payment_params) },
            headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
          )
        end.not_to change(SolidusSubscriptions::Subscription, :count)

        error_message = I18n.t('solidus_subscriptions.subscription.invalid_payment_details')
        response_body = JSON.parse(response.body)
        expect(response_body).to eq('payment_source_type' => [error_message])
        expect(response.status).to eq(422)
      end
    end

    context 'when an invalid payment source is provided' do
      it "doesn't create the subscription and responds with 422 Unprocessable Entity" do
        user = create(:user, &:generate_spree_api_key!)
        payment_source = create(:credit_card)
        payment_params = { payment_method_id: payment_source.payment_method.id }

        expect do
          post(
            api_v1_subscriptions_path,
            params: { subscription: { interval_length: 7 }.merge(payment_params) },
            headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
          )
        end.not_to change(SolidusSubscriptions::Subscription, :count)

        error_message = I18n.t('solidus_subscriptions.subscription.invalid_payment_details')
        response_body = JSON.parse(response.body)
        expect(response_body).to eq('payment_source_type' => [error_message])
        expect(response.status).to eq(422)
      end
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  describe 'PATCH /:id' do
    context 'when the subscription belongs to the user' do
      context 'with valid params' do
        it 'responds with 200 OK' do
          user = create(:user, &:generate_spree_api_key!)
          subscription = create(:subscription, user: user)

          patch(
            api_v1_subscription_path(subscription),
            params: { subscription: { interval_length: 11 } },
            headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
          )

          expect(response.status).to eq(200)
        end

        it 'updates the subscription' do
          user = create(:user, &:generate_spree_api_key!)
          subscription = create(:subscription, user: user)

          patch(
            api_v1_subscription_path(subscription),
            params: { subscription: { interval_length: 11 } },
            headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
          )

          expect(subscription.reload.interval_length).to eq(11)
        end
      end

      context 'with invalid params' do
        it 'responds with 422 Unprocessable Entity' do
          user = create(:user, &:generate_spree_api_key!)
          subscription = create(:subscription, user: user)

          patch(
            api_v1_subscription_path(subscription),
            params: { subscription: { interval_length: -1 } },
            headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
          )

          expect(response.status).to eq(422)
        end
      end
    end

    context 'when the subscription does not belong to the user' do
      it 'responds with 401 Unauthorized' do
        user = create(:user, &:generate_spree_api_key!)
        subscription = create(:subscription)

        patch(
          api_v1_subscription_path(subscription),
          params: { subscription: { interval_length: 11 } },
          headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
        )

        expect(response.status).to eq(401)
      end
    end
  end

  describe 'POST /:id/skip' do
    context 'when the subscription belongs to the user' do
      it 'responds with 200 OK' do
        user = create(:user, &:generate_spree_api_key!)
        subscription = create(:subscription, user: user)

        post(
          skip_api_v1_subscription_path(subscription),
          headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
        )

        expect(response.status).to eq(200)
      end

      it 'skips the subscription' do
        user = create(:user, &:generate_spree_api_key!)
        subscription = create(
          :subscription,
          user: user,
          interval_length: 1,
          interval_units: 'week',
          actionable_date: Time.zone.today,
        )

        post(
          skip_api_v1_subscription_path(subscription),
          headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
        )

        expect(subscription.reload.actionable_date).to eq(Time.zone.today + 1.week)
      end
    end

    context 'when the subscription does not belong to the user' do
      it 'responds with 401 Unauthorized' do
        user = create(:user, &:generate_spree_api_key!)
        subscription = create(:subscription)

        post(
          skip_api_v1_subscription_path(subscription),
          headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
        )

        expect(response.status).to eq(401)
      end
    end
  end

  describe 'POST /:id/cancel' do
    context 'when the subscription belongs to the user' do
      it 'responds with 200 OK' do
        user = create(:user, &:generate_spree_api_key!)
        subscription = create(:subscription, user: user)

        post(
          cancel_api_v1_subscription_path(subscription),
          headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
        )

        expect(response.status).to eq(200)
      end

      it 'cancels the subscription' do
        user = create(:user, &:generate_spree_api_key!)
        subscription = create(:subscription, user: user)

        post(
          cancel_api_v1_subscription_path(subscription),
          headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
        )

        expect(subscription.reload.state).to eq('canceled')
      end
    end

    context 'when the subscription does not belong to the user' do
      it 'responds with 401 Unauthorized' do
        user = create(:user, &:generate_spree_api_key!)
        subscription = create(:subscription)

        post(
          cancel_api_v1_subscription_path(subscription),
          headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
        )

        expect(response.status).to eq(401)
      end
    end
  end
end
