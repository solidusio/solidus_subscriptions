class AddAdnSpecificsToOrder < ActiveRecord::Migration[6.0]
  def change
    order = Spree::Order.new
    %i[order_type source dsr_id].each do |attr|
      next if order.respond_to? attr

      type = attr == :dsr_id ? :bigint : :integer
      add_column :spree_orders, attr, type
    end
  end
end
