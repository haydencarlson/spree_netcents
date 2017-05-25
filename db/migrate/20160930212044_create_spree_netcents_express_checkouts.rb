class CreateSpreeNetcentsExpressCheckouts < ActiveRecord::Migration
  def change
    create_table :spree_netcents_express_checkouts do |t|
      t.string :invoice_number
      t.string :status, :default => "complete"
      t.string :payer_id
    end
  end
end
