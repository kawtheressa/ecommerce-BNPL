# lib/tasks/setup_and_report.rake


namespace :db do
  desc "Seed the database and generate annual report"
  task setup_and_report: :environment do
    # Re-enable db:seed only if necessary for multiple invocations
    Rake::Task["db:seed"].reenable

    # Seed the database with CSV data
    puts "Starting database seeding..."
    Rake::Task["db:seed"].invoke
    puts "Database seeding complete."

    # Generate annual disbursements for each year
    puts "Generating Annual Disbursements."
    [ 2022, 2023 ].each do |year|
      AnnualDisbursementProcessor.new(year).process_all
    end
    puts "Annual Disbursements generated."

    # Generate annual report
    puts "Generating Annual Report."

    report_service = AnnualReportService.new
    report = report_service.generate_report
    puts report

    puts "Seeding and report generation complete."
  end
end
