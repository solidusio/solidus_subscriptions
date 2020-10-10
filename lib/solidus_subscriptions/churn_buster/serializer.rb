# frozen_string_literal: true

module SolidusSubscriptions
  module ChurnBuster
    class Serializer
      attr_reader :object

      class << self
        def serialize(object)
          new(object).to_h
        end
      end

      def initialize(object)
        @object = object
      end

      def to_h
        raise NotImplementedError
      end
    end
  end
end
