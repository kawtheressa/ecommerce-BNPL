# Merchant Disbursements

The app is designed to calculate disbursements based on various criteria, including commission schema per order amount and monthly fees for merchants. The project follows a **Domain-Driven Design (DDD)** structure to clearly separate domain logic from application and infrastructure concerns, providing flexibility, scalability, and maintainability.

## Table of Contents

- [Ruby Version](#ruby-version)
- [System Dependencies](#system-dependencies)
- [Project Setup](#project-setup)
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


### System Dependencies
- **PostgreSQL**
- **Sidekiq**

### Project Setup
```ruby 
bundle install
```

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
The seed file seeds.rb loads sample merchants and orders from **CSV** files.
```ruby
rake db:seed
```

Or by running this rake task which will seed the db with orders and merchants and also generate the annual disbursements for 2022 and 2023 it takes about **2 mins**:

```ruby
rake db:setup_and_report
```

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
- **Annual Report Service**: Generates an annual report for a given year.
- **Disbursement Worker**: Executes scheduled disbursement calculation by 8 UTC in the background (using Sidekiq).


### Technical Choices
The following are the primary design choices:

#### Domain-Driven Design (DDD):

The **DDD** approach was chosen to separate core business logic (domain layer) from application-specific logic. This structure simplifies testing and makes the application more modular and maintainable.
The domains folder contains all entities and rules related to the business logic. For example, **calculator.rb** contains the core calculation logic for disbursements.

#### Repository Pattern:
Repositories (repositories folder) encapsulate the logic required to access data sources, separating domain logic from data access code, and making it easier to switch to different data sources in the future.

#### Service Layer:
Services in the services folder manage application **logic**, such as disbursement processing and report generation, maintaining a clear distinction from domain logic.
By isolating business logic in services, we ensure that each service can evolve independently and remain highly testable  and reusable.



### Improvements
- **Improved error handling and logging**
- **Add more testing for edge cases**

## Generating and Printing the Annual Report

##### To generate and print the annual report, use the following:

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

1. Seed the database with orders and merchants provided in the CSV files.
2. Generate the disbursements for 2022 and 2023.
2. Generate the annual report for 2022 and 2023.
3. Print the report to the console.


## Annual Report Summary

| Year | Number of Disbursements | Amount Disbursed to Merchants | Amount of Order Fees | Number of monthly fees charged (From minimum monthly fee)	 | Amount of monthly fee charged (From minimum monthly fee)|
|------|--------------------------|-------------------------------|----------------------|-------------------------------|-------------------------------|
| 2022 | 94                       | 96,761.30 €                   | 967.78 €            | 1                             | 20.82 €                       |
| 2023 | 433                      | 15,059,089.42 €               | 133,854.78 €        | 0                             | 0.00 €                        |
