# db/migrate/20241104000000_create_monthly_fees.rb
class CreateMonthlyFees < ActiveRecord::Migration[7.2]
  def change
    create_table :monthly_fees, id: :uuid do |t|
      t.uuid :merchant_id, null: false
      t.date :fee_month, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :monthly_fees, [ :merchant_id, :fee_month ], unique: true
    add_foreign_key :monthly_fees, :merchants
  end
end
