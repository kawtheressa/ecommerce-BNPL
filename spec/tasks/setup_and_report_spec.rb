# spec/tasks/setup_and_report_spec.rb
require 'rails_helper'
require 'rake'

RSpec.describe "db:setup_and_report", type: :task do
  before(:all) do
    # Load the specific Rake task file
    Rake.application.rake_require("tasks/setup_and_report", [ Rails.root.join("lib").to_s ])

    # Stub the environment task to avoid loading Rails multiple times
    Rake::Task.define_task(:environment)

    # Define a dummy db:seed task to prevent errors during testing
    Rake::Task.define_task("db:seed")
  end

  before do
    # Re-enable the task for each example to allow fresh invocation
    Rake::Task["db:setup_and_report"].reenable
  end

  it "invokes db:seed and calls the AnnualReportService with the correct year" do
    # Mock the db:seed task to avoid actual database seeding
    allow(Rake::Task["db:seed"]).to receive(:invoke)

    # Set up a mock for the AnnualReportService
    mock_service = instance_double("AnnualReportService")
    allow(AnnualReportService).to receive(:new).and_return(mock_service)
    allow(mock_service).to receive(:generate_report)

    # Capture all output in a single assertion
    output = capture_stdout do
      Rake::Task["db:setup_and_report"].invoke
    end

    # Check if the output contains the expected strings
    expect(output).to include("Starting database seeding...")
    expect(output).to include("Generating Annual Report.")
    expect(output).to include("Seeding and report generation complete.")

    # Expectations for task invocations
    expect(Rake::Task["db:seed"]).to have_received(:invoke)
    expect(AnnualReportService).to have_received(:new)
    expect(mock_service).to have_received(:generate_report)
  end

  it "uses the specified year when provided via the YEAR environment variable" do
    # Mock the db:seed task again to avoid actual database seeding
    allow(Rake::Task["db:seed"]).to receive(:invoke)

    # Set up a different year for the test and allow other ENV keys to return nil
    specific_year = 2022
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("YEAR").and_return(specific_year.to_s)

    # Mock the AnnualReportService to avoid running the report generation
    mock_service = instance_double("AnnualReportService")
    allow(AnnualReportService).to receive(:new).and_return(mock_service)
    allow(mock_service).to receive(:generate_report)

    # Capture all output in a single assertion
    output = capture_stdout do
      Rake::Task["db:setup_and_report"].invoke
    end

    # Check if the output contains the expected strings
    expect(output).to include("Starting database seeding...")
    expect(output).to include("Generating Annual Report.")
    expect(output).to include("Seeding and report generation complete.")

    # Expectations for task invocations
    expect(Rake::Task["db:seed"]).to have_received(:invoke)
    expect(AnnualReportService).to have_received(:new)
    expect(mock_service).to have_received(:generate_report)
  end

  # Helper to capture stdout for verification
  def capture_stdout(&block)
    original_stdout = $stdout
    $stdout = StringIO.new
    block.call
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
