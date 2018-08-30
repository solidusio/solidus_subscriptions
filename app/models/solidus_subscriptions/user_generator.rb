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
      # I tried using `find_by` here but that has a strange conflict with
      # using `stub_authorization` in specs. `stub_authorization` adds an
      # `allow` on `Spree::User` that specifically targets `find_by`.
      Spree.user_class.where(email: order.email).first
    end

    def create_stub_user(order)
      initial_password = friendly_token
      user_attrs = {
        email: order.email,
        password: initial_password,
        password_confirmation: initial_password,
      }
      Spree.user_class.create!(user_attrs)
    end

    def friendly_token(length=20)
      SecureRandom.base64(length).tr('+/=', '-_ ').strip.delete("\n")
    end
  end
end
