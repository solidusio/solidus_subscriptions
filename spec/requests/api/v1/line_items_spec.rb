# frozen_string_literal: true

RSpec.describe '/api/v1/line_items' do
  include SolidusSubscriptions::Engine.routes.url_helpers

  describe 'PATCH /:id' do
    context 'when the subscription belongs to the user' do
      context 'with valid params' do
        it 'responds with 200 OK' do
          user = create(:user, &:generate_spree_api_key!)
          subscription = create(:subscription, user: user)
          line_item = create(:subscription_line_item, subscription: subscription)

          patch(
            api_v1_line_item_path(line_item),
            params: { subscription_line_item: { quantity: 11 } },
            headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
          )

          expect(response.status).to eq(200)
        end

        it 'updates the line item' do
          user = create(:user, &:generate_spree_api_key!)
          subscription = create(:subscription, user: user)
          line_item = create(:subscription_line_item, subscription: subscription)

          patch(
            api_v1_line_item_path(line_item),
            params: { subscription_line_item: { quantity: 11 } },
            headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
          )

          expect(line_item.reload.quantity).to eq(11)
        end
      end

      context 'with invalid params' do
        it 'responds with 422 Unprocessable Entity' do
          user = create(:user, &:generate_spree_api_key!)
          subscription = create(:subscription, user: user)
          line_item = create(:subscription_line_item, subscription: subscription)

          patch(
            api_v1_line_item_path(line_item),
            params: { subscription_line_item: { quantity: -1 } },
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
        line_item = create(:subscription_line_item, subscription: subscription)

        patch(
          api_v1_line_item_path(line_item),
          params: { subscription_line_item: { quantity: 11 } },
          headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
        )

        expect(response.status).to eq(401)
      end
    end
  end

  describe 'DELETE /:id' do
    context 'when the subscription belongs to the user' do
      it 'responds with 200 OK' do
        user = create(:user, &:generate_spree_api_key!)
        subscription = create(:subscription, user: user)
        line_item = create(:subscription_line_item, subscription: subscription)

        delete(
          api_v1_line_item_path(line_item),
          headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
        )

        expect(response.status).to eq(200)
      end

      it 'deletes the line item' do
        user = create(:user, &:generate_spree_api_key!)
        subscription = create(:subscription, user: user)
        line_item = create(:subscription_line_item, subscription: subscription)

        delete(
          api_v1_line_item_path(line_item),
          headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
        )

        expect { line_item.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the subscription does not belong to the user' do
      it 'responds with 401 Unauthorized' do
        user = create(:user, &:generate_spree_api_key!)
        subscription = create(:subscription)
        line_item = create(:subscription_line_item, subscription: subscription)

        delete(
          api_v1_line_item_path(line_item),
          headers: { 'Authorization' => "Bearer #{user.spree_api_key}" },
        )

        expect(response.status).to eq(401)
      end
    end
  end
end
