class AddSubscribableToSpreeVariants < ActiveRecord::Migration
  def change
    add_column :spree_variants, :subscribable, :boolean, default: false
  end
end
