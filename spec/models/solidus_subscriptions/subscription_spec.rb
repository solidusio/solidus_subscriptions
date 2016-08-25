require 'rails_helper'

RSpec.describe SolidusSubscriptions::Subscription, type: :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to validate_presence_of :user }
end
