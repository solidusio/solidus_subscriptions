class AddSubscribableToSpreeVariants < SolidusSupport::Migration[4.2]
  def change
    add_column :spree_variants, :subscribable, :boolean, default: false
  end
end
