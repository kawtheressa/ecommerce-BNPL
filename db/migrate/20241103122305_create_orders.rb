class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders, id: :uuid do |t|
      t.references :merchant, type: :uuid, null: false, foreign_key: true
      t.references :disbursement, type: :uuid, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
