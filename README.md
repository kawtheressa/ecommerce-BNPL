# Merchant Disbursements - BNPL

This application automates the calculation and reporting of merchant disbursements based on order volume and merchant activity. It handles:

##### 1. Disbursement Calculation
For each merchant order, the system calculates disbursements using a commission schema based on the order amount. These are scheduled and processed automatically using background jobs.

##### 2. Monthly Fee Application
Merchants have fixed monthly fee, applied only if their total commission doesn't reach a specified minimum. The app evaluates merchant activity and applies or skips this fee accordingly.

##### 3. Annual Report Generation
The system can generate a comprehensive annual report, summarizing:

- Total number of disbursements

- Total amount disbursed to merchants

- Total order fees collected

- Monthly fees applied (if any)

###### **Reports can be generated programmatically or via rake tasks and printed to the console.** 

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
- **Ruby**: 3.3.5
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


### ⚙️ Technical Choices
The project follows a Domain-Driven Design (DDD) structure for clear separation between domain logic, application services, and infrastructure.

#### Key Design Choices:

###### Domain Layer:
Located in the domains/ folder. Contains all core business logic like commission rules and fee calculation logic.

###### Repository Pattern:
Used to abstract data access logic and keep domain objects decoupled from ActiveRecord or external systems. Repositories are located in the repositories/ folder.

###### Service Layer:
Handles application-specific workflows such as disbursement processing and annual report generation. These services live in the services/ folder.

###### Background Processing:
Scheduled jobs (via Sidekiq) trigger disbursement calculations daily at 8 UTC using DisbursementWorker.



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

| Year | Number of Disbursements | Amount Disbursed to Merchants | Amount of Order Fees | Number of Monthly Fees Charged | Amount of Monthly Fee Charged |
|------|-------------------------|-------------------------------|-----------------------|---------------------------------|-------------------------------|
| 2022 | 94                      | 48,380.65 €                   | 483.89 €              | 1                               | 25.41 €                       |
| 2023 | 433                     | 7,529,544.71 €                | 66,927.39 €           | 0                               | 0.00 €                        |

