# db/seeds.rb

require 'csv'

# Set batch size for bulk insert
BATCH_SIZE = 1000

# Method to load merchants from CSV
def load_merchants
  puts "Starting merchant seeding from merchants.csv..."
  merchants = []
  total_merchants = 0

  begin
    CSV.foreach(Rails.root.join('./merchants.csv'), headers: true, col_sep: ';') do |row|
      begin
        merchants << {
          reference: row['reference'],
          email: row['email'],
          live_on: row['live_on'],
          disbursement_frequency: row['disbursement_frequency'],
          minimum_monthly_fee: row['minimum_monthly_fee'].to_d,
          created_at: Time.current,
          updated_at: Time.current
        }
      rescue StandardError => e
        puts "Error processing merchant row: #{row.inspect}"
        puts "Error details: #{e.message}"
        next  # Skip this row and continue with the next
      end

      # Insert batch of merchants
      if merchants.size >= BATCH_SIZE
        begin
          Merchant.insert_all(merchants)
          total_merchants += merchants.size
          puts "Inserted #{total_merchants} merchants so far..."
          merchants.clear
        rescue ActiveRecord::ActiveRecordError => e
          puts "Database error during merchant batch insert: #{e.message}"
          raise e  # Rethrow to stop if there's a serious database issue
        end
      end
    end

    # Insert remaining merchants
    unless merchants.empty?
      Merchant.insert_all(merchants)
      total_merchants += merchants.size
      puts "Inserted final batch of merchants. Total merchants inserted: #{total_merchants}"
    end
  rescue StandardError => e
    puts "Error loading merchants from CSV: #{e.message}"
    raise e  # Stop the process on a major CSV load error
  end
end

# Method to load orders from CSV
def load_orders
  puts "Starting order seeding from orders.csv..."
  orders = []
  total_orders = 0
  merchant_cache = Merchant.pluck(:reference, :id).to_h  # Cache merchants for faster lookup

  begin
    CSV.foreach(Rails.root.join('./orders.csv'), headers: true, col_sep: ';').with_index(1) do |row, index|
      begin
        merchant_id = merchant_cache[row['merchant_reference']]
        unless merchant_id
          puts "Warning: Merchant reference #{row['merchant_reference']} not found. Skipping order row #{index}."
          next
        end

        orders << {
          merchant_id: merchant_id,
          amount: row['amount'].to_d,
          created_at: row['created_at'],
          updated_at: Time.current
        }
      rescue StandardError => e
        puts "Error processing order row #{index}: #{row.inspect}"
        puts "Error details: #{e.message}"
        next
      end

      # Insert batch of orders
      if orders.size >= BATCH_SIZE
        begin
          Order.insert_all(orders)
          total_orders += orders.size
          puts "Inserted #{total_orders} orders so far..."
          orders.clear
        rescue ActiveRecord::ActiveRecordError => e
          puts "Database error during order batch insert: #{e.message}"
          raise e  # Rethrow to stop on a serious database issue
        end
      end

      # Provide progress feedback every 10,000 records
      puts "Processed #{index} records from orders.csv..." if (index % 10_000).zero?
    end

    # Insert remaining orders
    unless orders.empty?
      Order.insert_all(orders)
      total_orders += orders.size
      puts "Inserted final batch of orders. Total orders inserted: #{total_orders}"
    end
  rescue StandardError => e
    puts "Error loading orders from CSV: #{e.message}"
    raise e  # Stop the process on a major CSV load error
  end
end

# Run the seeding methods within a transaction for consistency
puts "Beginning seeding process..."
ActiveRecord::Base.transaction do
  begin
    load_merchants
    load_orders
  rescue StandardError => e
    puts "Seeding failed: #{e.message}"
    raise ActiveRecord::Rollback
  end
end
puts "Seeding complete!"
