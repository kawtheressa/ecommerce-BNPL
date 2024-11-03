class CreateMerchants < ActiveRecord::Migration[7.0]
  def change
    create_table :merchants, id: :uuid do |t|
      t.string :reference, null: false, unique: true
      t.string :email, null: false
      t.date :live_on, null: false
      t.string :disbursement_frequency, null: false
      t.decimal :minimum_monthly_fee, precision: 10, scale: 2, null: false, default: 0.0

      t.timestamps
    end

    add_index :merchants, :reference, unique: true
  end
end
