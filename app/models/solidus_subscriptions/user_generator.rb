# When a user purchases subscribable items, we need to associate their order
# with a Spree::User so that they can manage their subscriptions. Previously
# this meant preventing them from using guest checkout. We can work around this
# by creating a User record when the subscription is generated, if one does not
# already exist. They can then be directed to the password reset process for
# that user at a later time.
#
# It may also be the case that the user didn't login, but they already have an
# account under the email they entered for their order. In that case, it should
# be safe to associate this order with the same email.
module SolidusSubscriptions
  module UserGenerator
    extend self

    def find_or_create(order)
      existing_user(order) || create_stub_user(order)
    end

    private

    def existing_user(order)
      user_attrs = { email: order.email }.tap do |u_attrs|
        if user_team_enabled?
          u_attrs[:team_id] = order.store.team_id
        end
      end
      Spree.user_class.where(user_attrs).take
    end

    def create_stub_user(order)
      initial_password = friendly_token
      user_attrs = {
        email: order.email,
        password: initial_password,
        password_confirmation: initial_password,
      }
      if user_team_enabled?
        user_attrs[:team_id] = order.store.team_id
      end
      Spree.user_class.create!(user_attrs)
    end

    def friendly_token(length = 20)
      SecureRandom.base64(length).tr('+/=', '-_ ').strip.delete("\n")
    end

    # NOTE: this is not a great long-term solution for the problem of
    # "how do I account for teams in a way that handles the case where
    # the model has no Team attribute at all?"
    # Please use extreme caution when adapting this pattern elsewhere,
    # as it also introduces 2-way dependency on engine_storefront.
    def user_team_enabled?
      Spree.user_class.new.respond_to?(:team_id)
    end
  end
end
