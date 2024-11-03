class CreateDisbursements < ActiveRecord::Migration[7.0]
  def change
    create_table :disbursements, id: :uuid do |t|
      t.references :merchant, type: :uuid, null: false, foreign_key: true
      t.string :unique_reference, null: false, unique: true
      t.decimal :total_amount, precision: 15, scale: 2, null: false
      t.decimal :commission_fee, precision: 15, scale: 2, null: false
      t.date :disbursed_at, null: false

      t.timestamps
    end

    add_index :disbursements, :unique_reference, unique: true
  end
end
