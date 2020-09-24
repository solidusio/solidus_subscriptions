# frozen_string_literal: true

module Spree
  module Admin
    class InstallmentsController < ResourceController
      belongs_to 'subscription', model_class: SolidusSubscriptions::Subscription

      skip_before_action :load_resource, only: :index

      def index
        @search = collection.ransack((params[:q] || {}).reverse_merge(s: 'created_at desc'))

        @installments = @search.result(distinct: true).
                        page(params[:page]).
                        per(params[:per_page] || Spree::Config[:orders_per_page])
      end

      private

      def model_class
        ::SolidusSubscriptions::Installment
      end
    end
  end
end
