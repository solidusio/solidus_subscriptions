require 'rails_helper'

RSpec.describe SolidusSubscriptions::Dispatcher do
  describe '#dispatch' do
    subject { described_class.new([]).dispatch }

    it 'must be subclassed' do
      expect { subject }.to raise_error(
        RuntimeError,
        'A message should be set in subclasses of Dispatcher'
      )
    end
  end
end
