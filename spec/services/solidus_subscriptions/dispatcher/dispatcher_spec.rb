RSpec.describe SolidusSubscriptions::Dispatcher::Base do
  describe '#dispatch' do
    it 'raises a NotImplementedError' do
      dispatcher = described_class.new([])

      expect {
        dispatcher.dispatch
      }.to raise_error(NotImplementedError)
    end
  end
end
