# Merchant Disbursements

The app is designed to calculate disbursements based on various criteria, including commission schema per order amount and monthly fees for merchants. The project follows a **Domain-Driven Design (DDD)** structure to clearly separate domain logic from application and infrastructure concerns, providing flexibility, scalability, and maintainability.

## Table of Contents

- [Ruby Version](#ruby-version)
- [Project Setup](#project-setup)
- [System Dependencies](#system-dependencies)
- [Configuration](#configuration)
- [Database Creation](#database-creation)
- [Database Initialization](#database-initialization)
- [Running the Test Suite](#running-the-test-suite)
- [Services](#services-and-workers)
- [Technical Choices](#technical-choices)
- [Generating and Printing the Annual Report](#generating-and-printing-the-annual-report)

---

### Ruby Version
- **Ruby**: 3.2.2
- **Rails**: 7.2

### Project Setup
```ruby 
bundle install
```

### System Dependencies
- **PostgreSQL**: Database for storing merchants, orders, disbursements, and monthly fees.
- **Sidekiq**: Background job processing.

### Configuration
Configuration files are located in the `config` directory:
- `database.yml`: Configure your PostgreSQL database credentials.
- `application.rb`: Set application-specific configurations here.

### Database Creation
Run the following commands to create and set up the database:
```bash
rails db:create
rails db:migrate
```

### Database Initialization
Seed the database with initial data by running:

```ruby
rake db:seed
```
The seed file seeds.rb loads sample merchants and orders from CSV files.

Then you can run this service to generate the annual disbursements for 2022 and 2023:
```ruby
2022_annual_disbursements = AnnualDisbursementProcessor.new(2022)
2022_annual_disbursements.process_all


2023_annual_disbursements = AnnualDisbursementProcessor.new(2023)
2023_annual_disbursements.process_all
```

### Running the Test Suite
```ruby 
bundle exec rspec
```

### Services and Workers

- **Disbursement Service**: Calculates and generates disbursements for merchants.
- **Annual Disbursement Processor**: Processes annual disbursements for a given year.
- **Monthly Fee Calculator**: Calculates monthly fees based on merchant activity.
- **Disbursement Worker**: Executes scheduled disbursement calculation by 8 UTC in the background (using Sidekiq).


### Technical Choices
The following are the primary design choices and assumptions that influenced the structure and implementation of the project:

#### Domain-Driven Design (DDD):

The **DDD** approach was chosen to separate core business logic (domain layer) from application-specific logic. This structure simplifies testing and makes the application more modular and maintainable.
The domains folder contains all entities and rules related to the business logic. For example, **calculator.rb** contains the core calculation logic for disbursements.

#### Repository Pattern:

Repositories (repositories folder) encapsulate the logic required to access data sources, separating domain logic from data access code, and making it easier to switch to different data sources in the future.

#### Service Layer:
Services in the services folder manage application logic, such as disbursement processing and report generation, maintaining a clear distinction from domain logic.
By isolating business logic in services, we ensure that each service can evolve independently and remain highly testable.

#### Background Processing:

Time-consuming tasks, such as generating disbursements for all illegible marchants, are delegated to background workers (workers folder) to improve the application’s performance and scalability.


#### Testing:
Tests are organized in the spec directory by component type (models, services, workers, etc.). Using RSpec as the testing framework allows for a behavior-driven approach to testing the functionality.


## Generating and Printing the Annual Report

##### To generate and print the annual report directly in your code, use the following:

```ruby
rake db:seed
report_service = AnnualReportService.new
report = report_service.generate_report
puts report
```

##### Or by running the rake task:
```ruby 
rake db:setup_and_report
```
###### This task will:

1. Seed the database (if needed).
2. Generate the annual report for 2022 and 2023.
3. Print the report to the console.


## Annual Report Summary

| Year | Number of Disbursements | Amount Disbursed to Merchants | Amount of Order Fees | Number of Monthly Fees Charged | Amount of Monthly Fee Charged |
|------|--------------------------|-------------------------------|----------------------|-------------------------------|-------------------------------|
| 2022 | 94                       | 96,761.30 €                   | 967.78 €            | 1                             | 20.82 €                       |
| 2023 | 433                      | 15,059,089.42 €               | 133,854.78 €        | 0                             | 0.00 €                        |
