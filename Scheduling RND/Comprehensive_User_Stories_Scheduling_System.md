# Comprehensive User Stories for Scheduling and Time Management System

Based on the Complete HR System ERD, this document provides detailed user stories for all components of the scheduling, time management, accruals, and payroll system.

## Table of Contents
1. [Staff Scheduling System](#staff-scheduling-system)
2. [Attendance (Clock In/Out) System](#attendance-clock-inout-system)
3. [Time Management with Timesheets and Time Entries](#time-management-with-timesheets-and-time-entries)
4. [Job Codes and Work Codes Management System](#job-codes-and-work-codes-management-system)
5. [Accruals System](#accruals-system)
6. [Payroll System](#payroll-system)
7. [Rule Engine System](#rule-engine-system)
8. [Holiday Management System](#holiday-management-system)

---

## Staff Scheduling System

### 1. Shift Management

#### US-SS-001: Create Shift
**As a** scheduling manager  
**I want to** create new shifts with specific configurations  
**So that** I can define work periods with proper requirements and settings

**Acceptance Criteria:**
- [ ] Can create shifts with unique names and shift code
- [ ] Can set start date, start time, and end time
- [ ] Can configure minimum positions required
- [ ] Can set maximum time offs allowed
- [ ] Can specify location for the shift
- [ ] Can mark shift as work shift or non-work shift
- [ ] Can enable/disable self-scheduling
- [ ] Can require admin approval for self-scheduling
- [ ] Can hide open slots from view
- [ ] Can assign shift labels for categorization
- [ ] Can set background color for visual identification
- [ ] Can mark shift as active/inactive
- [ ] System validates time conflicts and overlapping shifts
- [ ] System prevents creation of shifts with invalid time ranges
- [ ] Shift can have work codes
- [ ] Shift Work codes are also linked to the employees, so employees with same work codes can work in the shifts and can be assigned only


#### US-SS-002: Manage Shift Labels
**As a** scheduling manager  
**I want to** create and manage shift labels  
**So that** I can categorize and organize shifts effectively

**Acceptance Criteria:**
- [ ] Can create shift labels with unique names and codes
- [ ] Can assign color codes and icon codes to labels
- [ ] Can set labels as active/inactive
- [ ] Can assign multiple labels to shifts
- [ ] Can filter and group shifts by labels
- [ ] System prevents duplicate label names and codes

#### US-SS-003: Configure Shift Work Codes
**As a** scheduling manager  
**I want to** assign work codes to shifts  
**So that** employees can be properly categorized when working specific shifts

**Acceptance Criteria:**
- [ ] Can assign multiple work codes to a shift
- [ ] Can mark work codes as required or optional
- [ ] Can set work codes as active/inactive for specific shifts
- [ ] Can view all work codes associated with a shift
- [ ] System validates work code assignments

### 2. Schedule Management

#### US-SS-004: Create Schedule
**As a** scheduling manager  
**I want to** create schedules  
**So that** I can organize shifts and assignments systematically

**Acceptance Criteria:**
- [ ] Can create schedules with unique names
- [ ] Can assign schedules to specific shifts
- [ ] Can set start and end dates for schedules
- [ ] Can set schedule status (draft, active, completed, cancelled)
- [ ] Can add notes and descriptions
- [ ] Can track who created the schedule
- [ ] System validates date ranges
- [ ] Schedule would be generic, i.e same schedule can be used to set the shift frequency, same schedule can be used to to set employee availability, same schedule would be used to assign employee on shift, so it would be like having source type and source id

#### US-SS-005: Configure Schedule Frequency
**As a** scheduling manager  
**I want to** set up recurring schedule patterns  
**So that** I can create time slots based on day of week for shift assignments

**Acceptance Criteria:**
- [ ] Can create schedule frequency patterns for specific days of the week
- [ ] Can set frequency as active/inactive
- [ ] Can create complex recurring patterns
- [ ] System shows available time slots based on schedule frequency
- [ ] System validates time conflicts within the same day
- [ ] System generates time slots for shift assignments based on frequency
- [ ] For a shift we can end old frequency and add new, it will basically create new shift, and will end old shift, new shift can have the same name or can have the different name

### 3. Staff Assignments

#### US-SS-006: Assign Staff to Shifts
**As a** scheduling manager  
**I want to** assign employees to specific shifts  
**So that** I can ensure proper coverage for all work periods

**Acceptance Criteria:**
- [ ] Can assign employees to shifts within schedules
- [ ] Can set assignment status (assigned, confirmed, cancelled, completed)
- [ ] Can add notes to assignments
- [ ] Can track who made the assignment and when
- [ ] Can assign specific work codes to assignments
- [ ] Can set custom start/end times for assignments
- [ ] Can set assignment frequency (one-time, recurring)
- [ ] System validates employee availability
- [ ] System prevents double-booking of employees
- [ ] System checks employee qualifications for work codes
- [ ] We can change employee assignment, it will end the old assignment frequency with end date, will create new assignment frequency with new start date

#### US-SS-007: Manage Employee Availability
**As an** employee  
**I want to** set my availability preferences  
**So that** managers can schedule me appropriately

**Acceptance Criteria:**
- [ ] Can set availability by day of week
- [ ] Can specify start and end times for each day
- [ ] Can mark days as available or unavailable
- [ ] Can set effective and expiry dates for availability
- [ ] Can update availability preferences
- [ ] Managers can view employee availability when scheduling
- [ ] System respects availability when auto-scheduling

### 4. Shift Trades and Swaps

#### US-SS-008: Request Shift Trade
**As an** employee  
**I want to** request to trade shifts with another employee  
**So that** I can manage my schedule flexibility

**Acceptance Criteria:**
- [ ] Can initiate trade requests with specific employees
- [ ] Can specify which assignments to trade
- [ ] Can provide reason for the trade request
- [ ] Can set trade duration limits
- [ ] Can request partial trades
- [ ] System validates both employees are eligible for the trade
- [ ] System checks work code compatibility
- [ ] System enforces trade board rules and settings

#### US-SS-009: Approve/Reject Shift Trades
**As a** manager  
**I want to** review and approve shift trade requests  
**So that** I can maintain proper staffing levels and employee satisfaction

**Acceptance Criteria:**
- [ ] Can view all pending trade requests
- [ ] Can approve or reject trade requests
- [ ] Can require additional approval levels
- [ ] Can set auto-approval for eligible trades
- [ ] Can track approval history and timestamps
- [ ] System notifies employees of trade status changes
- [ ] System automatically updates assignments upon approval
- [ ] We will need to rerun the same trade validations at time of approving, in case some other trade in same schedule time or overlaping with same schedule time is approved, so this approval not create any overlapping

#### US-SS-010: Configure Trade Board Settings
**As a** system administrator  
**I want to** configure trade board rules and settings  
**So that** I can control how shift trades are managed

**Acceptance Criteria:**
- [ ] Can limit trades to matching job code lists b.w employees
- [ ] Can limit trades to match Work code of employees + AND operator of shifts work codes
- [ ] Can require direct trades only
- [ ] Can require approval before sending requests
- [ ] Can require approval after acceptance
- [ ] Can require second approval for certain trades
- [ ] Can enable shift swap features
- [ ] Can color-code traded shifts
- [ ] Can require manual ledger approval
- [ ] Can allow users to select approvers
- [ ] Can configure job code specific rules (Like for which job code trades are allowed and for which job code trades are not allowed)

### 5. Gap Analysis and Coverage

#### US-SS-011: Identify Scheduling Gaps
**As a** scheduling manager  
**I want to** identify gaps in shift coverage  
**So that** I can ensure adequate staffing at all times

**Acceptance Criteria:**
- [ ] System identifies shifts with insufficient coverage
- [ ] System highlights shifts below minimum position requirements
- [ ] System shows available employees for unfilled shifts
- [ ] System provides gap analysis reports
- [ ] System can predict future gaps based on patterns
- [ ] System considers employee availability and qualifications

#### US-SS-012: Fill Empty Slots
**As a** scheduling manager  
**I want to** quickly fill empty shift slots  
**So that** I can maintain proper staffing levels

**Acceptance Criteria:**
- [ ] Can view all unfilled shifts
- [ ] Can see eligible employees for each shift
- [ ] Can auto-assign employees based on availability and qualifications
- [ ] Can manually assign employees to empty slots
- [ ] Can send notifications to eligible employees
- [ ] System prioritizes employees based on seniority or other criteria
- [ ] System prevents over-scheduling of employees

#### US-SS-013: Add Additional Resources
**As a** scheduling manager  
**I want to** add temporary or additional resources to shifts  
**So that** I can handle increased demand or coverage needs

**Acceptance Criteria:**
- [ ] Can add temporary employees to shifts
- [ ] Can increase minimum position requirements
- [ ] Can create additional shift instances
- [ ] Can assign external contractors or agency staff
- [ ] Can track additional resource costs
- [ ] System validates additional resource qualifications

### 6. Shift Groups and Shift Group assignments

#### US-SS-014: Manage Assignment Groups
**As a** scheduling manager  
**I want to** create and manage assignment groups  
**So that** I can organize employees and shifts more effectively

**Acceptance Criteria:**
- [ ] Can create assignment groups with unique names
- [ ] Can set group types (department, skill, location, etc.)
- [ ] Can assign color codes to groups
- [ ] Can add/remove employees from groups
- [ ] Can assign groups to shifts
- [ ] Can set groups as active/inactive
- [ ] System validates group assignments and permissions

---

## Attendance (Clock In/Out) System

### 1. Clock In/Out Management

#### US-ATT-001: Clock In
**As an** employee  
**I want to** clock in when I start work  
**So that** my work hours are accurately tracked

**Acceptance Criteria:**
- [ ] Can clock in using multiple methods (mobile app, web, kiosk, biometric)
- [ ] System records clock in time and location
- [ ] System validates employee is assigned to a shift
- [ ] System prevents early clock in beyond allowed buffer
- [ ] System records clock in method used
- [ ] System sets clock status to "clocked in"
- [ ] System validates employee is not already clocked in
- [ ] System can handle location-based clock in restrictions

#### US-ATT-002: Clock Out
**As an** employee  
**I want to** clock out when I finish work  
**So that** my work hours are accurately recorded

**Acceptance Criteria:**
- [ ] Can clock out using multiple methods
- [ ] System records clock out time and location
- [ ] System validates employee is currently clocked in
- [ ] System prevents clock out before minimum work duration
- [ ] System records clock out method used
- [ ] System sets clock status to "clocked out"
- [ ] System calculates total hours worked
- [ ] System can handle location-based clock out restrictions

#### US-ATT-003: View Clock History
**As an** employee  
**I want to** view my clock in/out history  
**So that** I can track my attendance and work hours

**Acceptance Criteria:**
- [ ] Can view clock in/out records for any date range
- [ ] Can see clock in/out times and locations
- [ ] Can see total hours worked per day
- [ ] Can see clock in/out methods used
- [ ] Can filter records by date, location, or method
- [ ] Can export clock history data
- [ ] System shows clock status for each record

#### US-ATT-004: Manage Clock Records
**As a** manager  
**I want to** manage employee clock records  
**So that** I can ensure accurate time tracking

**Acceptance Criteria:**
- [ ] Can view all employee clock records
- [ ] Can edit clock in/out times with proper authorization
- [ ] Can add notes to clock records
- [ ] Can approve or reject clock adjustments
- [ ] Can track who made changes and when
- [ ] Can generate attendance reports
- [ ] System maintains audit trail of all changes
- [ ] System requires manager approval for time adjustments

### 2. Location and Method Tracking

#### US-ATT-005: Configure Clock Locations
**As a** system administrator  
**I want to** configure clock in/out locations  
**So that** employees can only clock in/out from authorized locations

**Acceptance Criteria:**
- [ ] Can define clock locations with GPS coordinates
- [ ] Can set location radius for clock in/out
- [ ] Can assign locations to specific shifts
- [ ] Can enable/disable locations
- [ ] Can set location-specific clock rules
- [ ] System validates location when employees clock in/out
- [ ] System can handle multiple locations per facility

#### US-ATT-006: Configure Clock Methods
**As a** system administrator  
**I want to** configure available clock methods  
**So that** employees can use appropriate methods for their work environment

**Acceptance Criteria:**
- [ ] Can enable/disable different clock methods
- [ ] Can configure method-specific settings
- [ ] Can assign methods to specific locations
- [ ] Can set security requirements for each method
- [ ] Can track usage statistics for each method
- [ ] System validates method availability for each employee

---

## Time Management with Timesheets and Time Entries

### 1. Time Entry Management

#### US-TM-001: Create Time Entry
**As an** employee  
**I want to** create time entries for my work  
**So that** my hours are properly tracked and compensated

**Acceptance Criteria:**
- [ ] Can create time entries with start and end times
- [ ] Can create time entry with accrual rule id (if someone is adding on behalf of accrual consumption)
- [ ] Can select job code and work code for entries
- [ ] Can select time entry type (regular, overtime, sick, vacation, etc.)
- [ ] Can add descriptions and project codes
- [ ] Can specify cost centers
- [ ] Can link entries to clock in/out records
- [ ] Can add break duration
- [ ] System calculates total hours automatically
- [ ] System validates time entry against business rules
- [ ] System prevents overlapping time entries

#### US-TM-002: Edit Time Entry
**As an** employee  
**I want to** edit my time entries  
**So that** I can correct mistakes or add missing information

**Acceptance Criteria:**
- [ ] Can edit time entries before submission
- [ ] Can modify start/end times, descriptions, and codes
- [ ] Can add or remove break time
- [ ] Can change time entry types
- [ ] System recalculates total hours after edits
- [ ] System maintains edit history
- [ ] System prevents editing of approved entries without authorization

#### US-TM-003: Submit Time Entry
**As an** employee  
**I want to** submit my time entries for approval  
**So that** they can be processed for payroll

**Acceptance Criteria:**
- [ ] Can submit individual time entries
- [ ] Can submit multiple time entries at once
- [ ] System validates all required fields before submission
- [ ] System sets status to "submitted"
- [ ] System records submission timestamp
- [ ] System notifies approvers of pending entries
- [ ] System prevents submission of invalid entries

#### US-TM-004: Approve/Reject Time Entry
**As a** manager  
**I want to** review and approve time entries  
**So that** I can ensure accurate time reporting

**Acceptance Criteria:**
- [ ] Can view all pending time entries
- [ ] Can approve or reject individual entries
- [ ] Can add rejection reasons
- [ ] Can approve multiple entries at once
- [ ] System records approval/rejection with timestamp
- [ ] System notifies employees of status changes
- [ ] System prevents approval of invalid entries

### 2. Timesheet Management

#### US-TM-005: Create Timesheet
**As a** system  
**I want to** automatically create timesheets for pay periods  
**So that** employees can review and submit their time

**Acceptance Criteria:**
- [ ] System creates timesheets for each pay period
- [ ] System includes all time entries for the period
- [ ] System calculates total regular, overtime, and leave hours
- [ ] System sets initial status to "draft"
- [ ] System notifies employees of new timesheets
- [ ] System handles different pay period time types, like Weekly, Bi-Weekly, Monthly etc

#### US-TM-006: Review Timesheet
**As an** employee  
**I want to** review my timesheet before submission  
**So that** I can ensure accuracy before payroll processing

**Acceptance Criteria:**
- [ ] Can view all time entries in the timesheet
- [ ] Can see calculated totals for regular, overtime, and leave hours
- [ ] Can identify missing or incorrect entries
- [ ] Can add notes or comments
- [ ] Can request corrections if needed
- [ ] System highlights potential issues or discrepancies

#### US-TM-007: Submit Timesheet
**As an** employee  
**I want to** submit my timesheet for approval  
**So that** it can be processed for payroll

**Acceptance Criteria:**
- [ ] Can submit timesheet when all entries are complete
- [ ] System validates all time entries before submission
- [ ] System sets status to "submitted"
- [ ] System records submission timestamp
- [ ] System notifies approvers
- [ ] System prevents submission of incomplete timesheets

#### US-TM-008: Approve Timesheet
**As a** manager  
**I want to** approve employee timesheets  
**So that** they can be processed for payroll

**Acceptance Criteria:**
- [ ] Can view all submitted timesheets
- [ ] Can review individual time entries within timesheets
- [ ] Can approve or reject entire timesheets
- [ ] Can add approval comments
- [ ] System records approval with timestamp
- [ ] System notifies employees of approval status
- [ ] System prevents approval of invalid timesheets

### 3. Time Entry Types

#### US-TM-009: Manage Time Entry Types
**As a** system administrator  
**I want to** configure time entry types  
**So that** different types of work can be properly categorized

**Acceptance Criteria:**
- [ ] Can create time entry types with unique codes
- [ ] Can set type names and descriptions
- [ ] Can categorize types (regular, overtime, sick, vacation, etc.)
- [ ] Can mark types as paid or unpaid
- [ ] Can set accrual eligibility and factors
- [ ] Can require approval for certain types
- [ ] Can set maximum hours per day/week
- [ ] Can assign color codes for visual identification
- [ ] Can set types as active/inactive
- [ ] System validates type configurations
- [ ] 

### 4. Integration with Job and Work Codes

#### US-TM-010: Assign Job Codes to Time Entries
**As an** employee  
**I want to** assign job codes to my time entries  
**So that** my work is properly categorized for reporting, payroll, and accrual calculations

**Acceptance Criteria:**
- [ ] Can select from available job codes
- [ ] Can see job code descriptions and details
- [ ] Can see which accrual rules apply to selected job code
- [ ] System validates job code assignments
- [ ] System can auto-assign job codes based on shift assignments
- [ ] System tracks job code usage for reporting and accrual processing
- [ ] System links job code assignments to accrual rule applications
- [ ] Job codes will also help us at the time of payrolling and rate calculations

#### US-TM-011: Assign Work Codes to Time Entries
**As an** employee  
**I want to** assign work codes to my time entries  
**So that** my work activities are properly tracked

**Acceptance Criteria:**
- [ ] Can select from available work codes
- [ ] Can see work code details and pay multipliers
- [ ] System validates work code assignments
- [ ] System applies pay multipliers automatically
- [ ] System tracks work code usage for analysis
- [ ] System uses the work code at time of payrolling

#### US-TM-012: Link Job Code Changes to Accrual Recalculation
**As a** system  
**I want to** automatically recalculate accruals when job codes change  
**So that** employees receive correct accrual rates based on their new job role

**Acceptance Criteria:**
- [ ] System detects job code changes for employees
- [ ] System identifies which accrual rules need to be recalculated
- [ ] System applies new accrual rules based on new job code
- [ ] System maintains history of accrual rule changes
- [ ] System notifies employees of accrual rate changes
- [ ] System creates audit trail of job code and accrual rule changes

---

## Job Codes and Work Codes Management System

### 1. Job Code Management

#### US-JC-001: Create Job Codes
**As a** system administrator  
**I want to** create job codes for different employee roles  
**So that** I can categorize employees and apply appropriate accrual rules

**Acceptance Criteria:**
- [ ] Can create job codes with unique codes and names
- [ ] Can set job code descriptions and requirements
- [ ] Can assign job codes to employees
- [ ] Can set job code status (active/inactive)
- [ ] Can configure job code specific settings
- [ ] System validates job code uniqueness
- [ ] System prevents duplicate job code creation

#### US-JC-002: Manage Job Code Assignments
**As a** system administrator  
**I want to** assign job codes to employees  
**So that** employees can be properly categorized and receive appropriate benefits

**Acceptance Criteria:**
- [ ] Can assign job codes to individual employees
- [ ] Can assign job codes to employee groups
- [ ] Can set effective dates for job code assignments
- [ ] Can change employee job codes with proper authorization
- [ ] Can view all employees assigned to specific job codes
- [ ] System validates job code assignments
- [ ] System maintains history of job code changes

#### US-JC-003: Configure Job Code Accrual Rules
**As a** system administrator  
**I want to** configure accrual rules for specific job codes  
**So that** employees with different roles receive appropriate accrual benefits

**Acceptance Criteria:**
- [ ] Can assign accrual rules to job codes
- [ ] Can set different accrual rules for different job codes
- [ ] Can set effective and expiry dates for job code accrual rules
- [ ] Can view all accrual rules assigned to a job code
- [ ] System validates job code accrual rule assignments
- [ ] System prevents conflicting accrual rule assignments

### 2. Work Code Management

#### US-WC-001: Create Work Codes
**As a** system administrator  
**I want to** create work codes for different work activities  
**So that** I can track and categorize different types of work performed

**Acceptance Criteria:**
- [ ] Can create work codes with unique codes and names
- [ ] Can set work code descriptions and categories
- [ ] Can configure work code pay multipliers
- [ ] Can set work code status (active/inactive)
- [ ] Can assign work codes to job codes
- [ ] System validates work code uniqueness
- [ ] System prevents duplicate work code creation

#### US-WC-002: Configure Work Code Pay Multipliers
**As a** system administrator  
**I want to** configure pay multipliers for work codes  
**So that** employees receive appropriate compensation for different work activities

**Acceptance Criteria:**
- [ ] Can set pay multipliers for work codes (e.g., 1.0x, 1.5x, 2.0x)
- [ ] Can configure different multipliers for different job codes
- [ ] Can set effective dates for pay multipliers
- [ ] Can view all work codes and their multipliers
- [ ] System validates pay multiplier configurations
- [ ] System applies multipliers during payroll calculations

#### US-WC-003: Assign Work Codes to Time Entries
**As an** employee  
**I want to** assign work codes to my time entries  
**So that** my work activities are properly tracked and compensated

**Acceptance Criteria:**
- [ ] Can select work codes from available list
- [ ] Can see work code descriptions and pay multipliers
- [ ] Can assign single work code to single time entry
- [ ] System validates work code assignments
- [ ] System applies pay multipliers automatically
- [ ] System tracks work code usage for reporting

#### US-WC-004: Manage Work Code Categories
**As a** system administrator  
**I want to** organize work codes into categories  
**So that** I can better manage and report on different types of work

**Acceptance Criteria:**
- [ ] Can create work code categories (regular, overtime, special projects, etc.)
- [ ] Can assign work codes to categories
- [ ] Can filter work codes by category
- [ ] Can view work code usage by category
- [ ] Can generate reports by work code category
- [ ] System validates category assignments
- [ ] System maintains category relationships

### 3. Integration with Accrual System

#### US-JC-WC-001: Link Job Codes to Accrual Rules
**As a** system  
**I want to** automatically apply accrual rules based on job codes  
**So that** employees receive correct accruals based on their role

**Acceptance Criteria:**
- [ ] System automatically applies job code accrual rules to employees
- [ ] System recalculates accruals when job codes change
- [ ] System maintains accrual rule history for job code changes
- [ ] System validates job code accrual rule assignments
- [ ] System provides audit trail of job code accrual rule applications

#### US-JC-WC-002: Generate Job Code and Work Code Reports
**As a** manager  
**I want to** generate reports on job code and work code usage  
**So that** I can analyze work patterns and make informed decisions

**Acceptance Criteria:**
- [ ] Can generate job code assignment reports
- [ ] Can generate work code usage reports
- [ ] Can generate accrual rule application reports by job code
- [ ] Can generate pay multiplier reports by work code
- [ ] Can export reports in various formats
- [ ] System provides real-time and historical reporting
- [ ] System tracks trends and patterns in job code and work code usage

---

## Accruals System

### Accrual Rules Categorization System

| Parent Category | Child Category | Accrual Type | Description | Earning Method | Rate Determination |
|----------------|----------------|--------------|-------------|----------------|-------------------|
| **Time Entry Based** | Fixed Rate | Sick Leave | 40 hours/year, earned only when working | Based on logged work hours | Constant rate regardless of tenure |
| **Time Entry Based** | Tenure-Based Rate | Vacation | Rate increases with tenure, earned only when working | Based on logged work hours | Rate varies by years of service |
| **Non-Time Entry Based** | Fixed Rate | Personal Days | 20 hours/year, earned automatically | Automatic (daily/pay period) | Constant rate regardless of tenure |
| **Non-Time Entry Based** | Tenure-Based Rate | Holiday Time | Rate increases with tenure, earned automatically | Automatic (daily/pay period) | Rate varies by years of service |

#### Detailed Breakdown

**Time Entry Based Rules**
| Child Category | Accrual Type | How It Works | Example |
|----------------|--------------|--------------|---------|
| **Fixed Rate** | Sick Leave | Employee works 8 hours → Gets 0.15 hours sick leave<br>Employee works 10 hours → Gets 0.19 hours sick leave<br>Employee works 4 hours → Gets 0.08 hours sick leave | 40 hours/year ÷ 2080 hours = 0.019 hours per hour worked |
| **Tenure-Based Rate** | Vacation | 0-2 years: Employee works 8 hours → Gets 0.15 hours sick leave<br>2-5 years: Employee works 8 hours → Gets 0.20 hours sick leave<br>5+ years: Employee works 8 hours → Gets 0.30 hours sick leave | Rate increases with tenure, earned only when working |

**Non-Time Entry Based Rules**
| Child Category | Accrual Type | How It Works | Example |
|----------------|--------------|--------------|---------|
| **Fixed Rate** | Personal Days | Employee gets 0.055 hours daily regardless of work hours<br>Same rate for all employees with same job code | 20 hours/year ÷ 365 days = 0.055 hours per day |
| **Tenure-Based Rate** | Holiday Time | 0-1 year: 0 hours/year, earned automatically<br>1+ years: 40 hours/year, earned automatically <br> ** This both fixed or tenure based rate get granted at start of the year so employee can avail those leaves ** | Rate increases with tenure, earned automatically |

#### System Validation Rules

| Rule | Description |
|------|-------------|
| **Unique Parent Category** | Each accrual type can only have one parent category (Time Entry Based OR Non-Time Entry Based) |
| **Unique Child Category** | Each accrual type can only have one child category (Fixed Rate OR Tenure-Based Rate) |
| **Unique Combination** | Job Code + Accrual Type + Parent Category + Child Category = Unique |
| **No Mixing** | Cannot mix Time Entry Based with Non-Time Entry Based for same accrual type |
| **No Mixing** | Cannot mix Fixed Rate with Tenure-Based Rate for same accrual type |

### 1. Accrual Type Management

#### US-ACC-001: Create Accrual Types
**As a** system administrator  
**I want to** create accrual types for different time off categories  
**So that** employees can accrue various types of leave

**Acceptance Criteria:**
- [ ] Can create accrual types with unique codes
- [ ] Can set type names and descriptions
- [ ] Can specify units (hours, days, etc.)
- [ ] Can categorize types (vacation, sick, personal, etc.)
- [ ] Can set maximum balance limits
- [ ] Can set carryover limits and expiry periods
- [ ] Can mark types as active/inactive
- [ ] System validates accrual type configurations

#### US-ACC-002: Configure Job Code Accrual Rules with Two-Level Categorization
**As a** system administrator  
**I want to** configure accrual rules for job codes using two-level categorization system  
**So that** employees accrue time off according to their job role, tenure, and earning method

**Acceptance Criteria:**
- [ ] Can set parent category as either 'time_entry_based' or 'non_time_entry_based' for each accrual type
- [ ] Can set child category as either 'fixed_rate' or 'tenure_based_rate' for each accrual type
- [ ] Can configure fixed rates that apply regardless of tenure
- [ ] Can configure tenure-based rates with multiple tenure ranges
- [ ] Can set different accrual types with different parent categories within same job code
- [ ] Can set different accrual types with different child categories within same job code
- [ ] Can set effective and expiry dates for rules
- [ ] Can enable/disable individual rules
- [ ] System validates that each job code + accrual type combination has only one parent category
- [ ] System validates that each job code + accrual type combination has only one child category
- [ ] System prevents conflicting rule configurations

#### US-ACC-003: Configure Time-Entry Based Accrual Rules
**As a** system administrator  
**I want to** configure accrual rules that are earned only when employees log time  
**So that** certain accrual types are earned based on actual work performed

**Acceptance Criteria:**
- [ ] Can set accrual rules with parent category 'time_entry_based'
- [ ] Can configure fixed rates for time-entry based accruals
- [ ] Can configure tenure-based rates for time-entry based accruals
- [ ] Can set different parent categories for different accrual types within same job code
- [ ] Can specify that accruals are only earned when time is logged
- [ ] Can configure standard working hours (e.g., 8 hours per day) for accrual calculations
- [ ] System calculates accruals based on actual hours worked in time entries
- [ ] System validates time-entry based rule configurations
- [ ] System prevents mixing time-entry based with non-time-entry based for same accrual type

#### US-ACC-004: Configure Non-Time-Entry Based Accrual Rules
**As a** system administrator  
**I want to** configure accrual rules that are earned automatically  
**So that** certain accrual types are earned based on employment status regardless of time logged

**Acceptance Criteria:**
- [ ] Can set accrual rules with parent category 'non_time_entry_based'
- [ ] Can configure fixed rates for automatic accruals
- [ ] Can configure tenure-based rates for automatic accruals
- [ ] Can set different parent categories for different accrual types within same job code
- [ ] Can specify that accruals are earned automatically based on employment status
- [ ] System calculates accruals daily regardless of time entries
- [ ] System validates non-time-entry based rule configurations
- [ ] System prevents mixing non-time-entry based with time-entry based for same accrual type

#### US-ACC-005: Configure Fixed Rate Accrual Rules
**As a** system administrator  
**I want to** configure accrual rules with fixed rates  
**So that** certain accrual types have consistent rates regardless of employee tenure

**Acceptance Criteria:**
- [ ] Can set accrual rules with child category 'fixed_rate'
- [ ] Can set fixed accrual rates for specific job code + accrual type combinations
- [ ] Can specify that fixed rates apply to all employees with that job code
- [ ] Can set different fixed rates for different accrual types within same job code
- [ ] Can configure fixed rules for roles where tenure doesn't affect benefits
- [ ] System applies fixed rates consistently across all employees with matching job code
- [ ] System validates fixed rate configurations
- [ ] System prevents mixing fixed rate with tenure-based rate for same accrual type

#### US-ACC-006: Configure Tenure-Based Rate Accrual Rules
**As a** system administrator  
**I want to** configure accrual rules with tenure-based rates  
**So that** certain accrual types increase based on employee years of service

**Acceptance Criteria:**
- [ ] Can set accrual rules with child category 'tenure_based_rate'
- [ ] Can create tenure ranges with minimum and maximum years
- [ ] Can set different accrual rates for each tenure range
- [ ] Can configure open-ended ranges (e.g., 10+ years)
- [ ] Can set different tenure progressions for different accrual types
- [ ] Can configure waiting periods (e.g., no accrual for first year)
- [ ] System validates that tenure ranges don't overlap
- [ ] System validates that tenure ranges cover all possible years
- [ ] System automatically applies correct rate based on employee tenure
- [ ] System prevents mixing tenure-based rate with fixed rate for same accrual type

#### US-ACC-007: Validate Accrual Rule Configurations
**As a** system administrator  
**I want to** validate accrual rule configurations  
**So that** there are no conflicts or gaps in accrual calculations

**Acceptance Criteria:**
- [ ] System validates that each job code + accrual type + parent category combination is unique
- [ ] System validates that each job code + accrual type + child category combination is unique
- [ ] System prevents duplicate rule configurations
- [ ] System validates tenure range configurations (no overlaps, complete coverage)
- [ ] System validates that fixed rates are non-negative
- [ ] System validates that tenure-based rates are non-negative
- [ ] System prevents mixing parent categories for same accrual type
- [ ] System prevents mixing child categories for same accrual type
- [ ] System validates standard working hours configuration for time-entry based rules
- [ ] System provides clear error messages for invalid configurations
- [ ] System prevents saving invalid rule configurations

### 2. Accrual Processing

#### US-ACC-008: Process Time-Entry Based Accruals
**As a** system  
**I want to** automatically process accruals when time entries are logged  
**So that** employees earn accruals based on actual work performed

**Acceptance Criteria:**
- [ ] System processes accruals immediately when time entries are created
- [ ] System calculates accruals based on actual hours worked in time entries
- [ ] System applies job code rules to determine accrual rates
- [ ] System applies fixed or tenure-based rates based on rule configuration
- [ ] System calculates hourly accrual rates from annual rates
- [ ] System uses standard working hours (e.g., 8 hours) as base for calculations
- [ ] System proportionally calculates accruals for different hours worked (e.g., 10 hours = 1.25x accrual)
- [ ] System deposits earned accruals into employee accrual banks
- [ ] System creates accrual transactions with time entry references
- [ ] System updates employee balances in real-time

#### US-ACC-023: Calculate Hourly Accrual Rates
**As a** system  
**I want to** calculate accrual rates based on actual hours worked  
**So that** employees earn proportional accruals for different work hours

**Acceptance Criteria:**
- [ ] System calculates hourly accrual rates from annual rates (annual rate ÷ 2080 hours)
- [ ] System applies hourly rates to actual hours worked in time entries
- [ ] System handles standard working hours (8 hours) as base calculation
- [ ] System proportionally calculates accruals for overtime hours (e.g., 10 hours = 1.25x base accrual)
- [ ] System proportionally calculates accruals for part-time hours (e.g., 4 hours = 0.5x base accrual)
- [ ] System handles different work patterns (4-hour days, 12-hour shifts, etc.)
- [ ] System calculates accruals for both fixed rate and tenure-based rate rules
- [ ] System maintains calculation accuracy for fractional hours
- [ ] System creates detailed calculation logs showing hourly breakdowns

#### US-ACC-009: Process Non-Time-Entry Based Accruals
**As a** system  
**I want to** automatically process accruals based on employment status  
**So that** employees earn accruals regardless of time logged

**Acceptance Criteria:**
- [ ] System processes accruals daily based on employment status
- [ ] System calculates accruals regardless of time entries
- [ ] System applies job code rules to determine accrual rates
- [ ] System applies fixed or tenure-based rates based on rule configuration
- [ ] System calculates daily accrual rates from annual rates
- [ ] System deposits earned accruals into employee accrual banks
- [ ] System creates accrual transactions with employment status references
- [ ] System updates employee balances automatically

#### US-ACC-010: Calculate Tenure-Based Rate Accruals
**As a** system  
**I want to** calculate accruals based on employee tenure  
**So that** employees receive appropriate rates based on their years of service

**Acceptance Criteria:**
- [ ] System calculates employee tenure based on hire date
- [ ] System determines correct tenure range for each accrual type
- [ ] System applies appropriate rate for current tenure range
- [ ] System handles employees at tenure range boundaries
- [ ] System processes tenure-based accruals for all applicable accrual types
- [ ] System creates detailed calculation logs with tenure information
- [ ] System applies tenure-based rates for both time-entry and non-time-entry based accruals

#### US-ACC-011: Calculate Fixed Rate Accruals
**As a** system  
**I want to** calculate accruals using fixed rates  
**So that** employees receive consistent rates regardless of tenure

**Acceptance Criteria:**
- [ ] System applies fixed rates for accrual types configured as fixed
- [ ] System applies same rate to all employees with matching job code
- [ ] System processes fixed rate accruals independently from tenure-based
- [ ] System handles job code changes and applies new fixed rates
- [ ] System creates calculation records for fixed rate accruals
- [ ] System applies fixed rates for both time-entry and non-time-entry based accruals

#### US-ACC-012: Process Manual Accruals
**As a** manager  
**I want to** manually adjust employee accrual balances  
**So that** I can handle special circumstances or corrections

**Acceptance Criteria:**
- [ ] Can add or subtract hours from employee balances
- [ ] Can specify reason for manual adjustment
- [ ] Can set effective date for adjustments
- [ ] Can require approval for large adjustments
- [ ] System creates accrual transactions for manual adjustments
- [ ] System maintains audit trail of all adjustments
- [ ] System notifies employees of balance changes

#### US-ACC-013: Process Accrual Consumption
**As a** system  
**I want to** process accrual consumption when employees take time off  
**So that** accrual balances are reduced when time off is used

**Acceptance Criteria:**
- [ ] System processes time off requests and checks accrual balances
- [ ] System validates sufficient accrual balance for time off request
- [ ] System deducts consumed accruals from employee accrual banks
- [ ] System creates time entries for time off with accrual consumption
- [ ] System creates accrual transactions for consumption
- [ ] System updates employee balances when time off is taken
- [ ] System prevents time off when insufficient accrual balance
- [ ] System maintains audit trail of all accrual consumption

### 3. Accrual Balance Management

#### US-ACC-014: View Accrual Balances with Categorization Information
**As an** employee  
**I want to** view my current accrual balances with parent and child category information  
**So that** I can understand how my balances are calculated and plan my time off usage

**Acceptance Criteria:**
- [ ] Can view current balance for each accrual type
- [ ] Can see which accrual types use time-entry based vs non-time-entry based parent categories
- [ ] Can see which accrual types use fixed rate vs tenure-based rate child categories
- [ ] Can see pending balance (not yet processed)
- [ ] Can see used balance for the period
- [ ] Can see carryover balance and expiry dates
- [ ] Can view balance history and transactions with categorization details
- [ ] Can see projected future accruals based on current rules
- [ ] System updates balances in real-time
- [ ] System shows parent category (time-entry/non-time-entry) and child category (fixed/tenure-based) for each accrual type

#### US-ACC-015: Manage Accrual Balances with Categorization Information
**As a** manager  
**I want to** manage employee accrual balances with parent and child category information  
**So that** I can ensure accurate time off tracking and understand rule applications

**Acceptance Criteria:**
- [ ] Can view all employee accrual balances
- [ ] Can see which parent and child categories are applied to each employee's accruals
- [ ] Can search and filter by employee, job code, or accrual type
- [ ] Can filter by parent category (time-entry based vs non-time-entry based)
- [ ] Can filter by child category (fixed rate vs tenure-based rate)
- [ ] Can export balance reports with categorization information
- [ ] Can identify employees with low or high balances
- [ ] Can track accrual trends and patterns by parent and child categories
- [ ] System provides balance summary reports with categorization breakdowns

#### US-ACC-016: View Accrual Rule Status
**As a** manager  
**I want to** view the status of accrual rules for employees  
**So that** I can understand which rules are being applied and troubleshoot issues

**Acceptance Criteria:**
- [ ] Can view which job code rules apply to each employee
- [ ] Can see which accrual types use time-entry based vs non-time-entry based parent categories
- [ ] Can see which accrual types use fixed rate vs tenure-based rate child categories
- [ ] Can view employee tenure and current tenure ranges
- [ ] Can see effective and expiry dates for rules
- [ ] Can identify employees with missing or invalid rule assignments
- [ ] Can view rule change history and impact
- [ ] System provides rule status dashboard with parent and child category information

### 4. Accrual Transactions

#### US-ACC-017: Track Accrual Transactions with Categorization Information
**As a** system  
**I want to** track all accrual transactions with parent and child category information  
**So that** there is a complete audit trail of balance changes and rule applications

**Acceptance Criteria:**
- [ ] System records all accrual transactions
- [ ] System tracks transaction types (earned, consumed, adjustment, carryover)
- [ ] System records amounts and resulting balances
- [ ] System records parent category used for each transaction (time-entry based/non-time-entry based)
- [ ] System records child category used for each transaction (fixed rate/tenure-based rate)
- [ ] System records job code and tenure information for each transaction
- [ ] System links transactions to time entries when applicable
- [ ] System records processing dates and responsible users
- [ ] System maintains transaction history for reporting
- [ ] System can reverse transactions if needed
- [ ] System provides detailed transaction reports by parent and child categories

#### US-ACC-018: Audit Accrual Rule Applications
**As a** system administrator  
**I want to** audit how accrual rules are being applied  
**So that** I can ensure rules are working correctly and identify issues

**Acceptance Criteria:**
- [ ] System tracks which rules were applied to each employee
- [ ] System records rule calculation details and results
- [ ] System identifies rule application errors or conflicts
- [ ] System provides audit reports for rule compliance
- [ ] System tracks rule changes and their impact on calculations
- [ ] System maintains audit trail for rule modifications
- [ ] System can generate rule application reports by time period
- [ ] System tracks parent and child category usage patterns

#### US-ACC-019: Manage Job Code Accrual Rule Assignments
**As a** system administrator  
**I want to** manage which accrual rules apply to which job codes  
**So that** I can ensure proper rule assignments and prevent conflicts

**Acceptance Criteria:**
- [ ] Can assign accrual rules to specific job codes
- [ ] Can set different parent categories for different accrual types within same job code
- [ ] Can set different child categories for different accrual types within same job code
- [ ] Can view all rule assignments for a job code
- [ ] Can modify rule assignments and effective dates
- [ ] Can remove rule assignments when no longer needed
- [ ] System validates that each job code + accrual type has only one parent category
- [ ] System validates that each job code + accrual type has only one child category
- [ ] System prevents conflicting rule assignments
- [ ] System provides rule assignment reports with parent and child category information

#### US-ACC-020: Configure Accrual Rule Dependencies
**As a** system administrator  
**I want to** configure dependencies between accrual rules  
**So that** complex accrual scenarios can be handled properly

**Acceptance Criteria:**
- [ ] Can set up rule dependencies (e.g., personal days only after 1 year)
- [ ] Can configure waiting periods for accrual types
- [ ] Can set up conditional accruals based on other accrual types
- [ ] Can configure maximum total accrual limits across all types
- [ ] System validates dependency configurations
- [ ] System processes dependencies correctly during accrual calculations
- [ ] System provides dependency validation reports

#### US-ACC-021: Handle Job Code Changes and Accrual Recalculation
**As a** system  
**I want to** automatically handle accrual recalculation when job codes change  
**So that** employees receive correct accrual rates based on their new job role

**Acceptance Criteria:**
- [ ] System detects when employee job codes change
- [ ] System identifies which accrual rules need to be recalculated
- [ ] System applies new accrual rules based on new job code
- [ ] System maintains history of accrual rule changes
- [ ] System notifies employees of accrual rate changes
- [ ] System creates audit trail of job code and accrual rule changes
- [ ] System handles retroactive accrual adjustments if needed
- [ ] System recalculates both time-entry based and fixed earning mode accruals
- [ ] **Accrual Balance Preservation:** System preserves existing accrual balances when job code changes (balances belong to employee, not job code)
- [ ] **Same Accrual Type:** If new job code has same accrual type (e.g., both have "Sick Leave"), existing balance is preserved and future accruals use new job code's rules
- [ ] **Different Accrual Types:** If new job code has different accrual types, employee maintains separate balances for each accrual type
- [ ] **Missing Accrual Type:** If new job code doesn't have an accrual type that employee has balance for, existing balance remains but no new accruals are earned for that type
- [ ] **Balance Continuity:** Employee does NOT receive duplicate balances when job code changes - existing balance continues to be available for consumption
- [ ] **Future Accruals:** Only future accruals (earned after job code change) use the new job code's accrual rules and rates
- [ ] **Historical Tracking:** System maintains audit trail showing which job code was used when each accrual transaction occurred
- [ ] **Balance Display:** System shows accrual balances with indication of which job code rules currently apply for future accruals

#### US-ACC-022: Generate Accrual Reports with Categorization Information
**As a** manager  
**I want to** generate reports showing how accrual rules are working  
**So that** I can monitor system performance and make informed decisions

**Acceptance Criteria:**
- [ ] Can generate reports showing time-entry based vs non-time-entry based parent category usage
- [ ] Can generate reports showing fixed rate vs tenure-based rate child category usage
- [ ] Can view accrual calculations by job code, parent category, and child category
- [ ] Can track rule effectiveness and employee satisfaction
- [ ] Can identify employees with unusual accrual patterns
- [ ] Can generate compliance reports for audit purposes
- [ ] Can export reports in various formats
- [ ] System provides real-time and historical reporting capabilities
- [ ] System provides parent and child category breakdowns in reports

---

## Payroll System

### 1. Pay Period Management

#### US-PAY-001: Create Pay Periods
**As a** payroll administrator  
**I want to** create pay periods  
**So that** payroll can be processed on schedule

**Acceptance Criteria:**
- [ ] Can create pay periods with unique names
- [ ] Can set start and end dates
- [ ] Can set pay dates
- [ ] Can specify frequency (weekly, bi-weekly, monthly, etc.)
- [ ] Can set pay period status
- [ ] System validates date ranges and frequencies
- [ ] System prevents overlapping pay periods

#### US-PAY-002: Manage Pay Period Status
**As a** payroll administrator  
**I want to** manage pay period status  
**So that** I can control the payroll processing workflow

**Acceptance Criteria:**
- [ ] Can set pay period status (draft, open, closed, processed)
- [ ] Can close pay periods to prevent further changes
- [ ] Can reopen closed periods with proper authorization
- [ ] System enforces status-based restrictions
- [ ] System tracks status change history

### 2. Payroll Processing

#### US-PAY-003: Calculate Payroll
**As a** system  
**I want to** automatically calculate payroll for employees  
**So that** accurate pay amounts are determined

**Acceptance Criteria:**
- [ ] System calculates regular hours from time entries
- [ ] System calculates overtime hours based on rules
- [ ] System calculates double time hours
- [ ] System calculates holiday hours
- [ ] System calculates sick, vacation, and personal hours
- [ ] System applies appropriate pay rates and multipliers
- [ ] System calculates gross pay
- [ ] System applies deductions
- [ ] System calculates net pay
- [ ] System handles different pay frequencies

#### US-PAY-004: Process Payroll Items
**As a** system  
**I want to** process individual payroll items  
**So that** detailed payroll calculations are maintained

**Acceptance Criteria:**
- [ ] System creates payroll items for each component
- [ ] System categorizes items (earnings, deductions, taxes)
- [ ] System calculates item amounts and rates
- [ ] System applies pre-tax/post-tax rules
- [ ] System tracks item hours and rates
- [ ] System maintains item-level audit trail

#### US-PAY-005: Approve Payroll
**As a** payroll manager  
**I want to** review and approve payroll calculations  
**So that** I can ensure accuracy before payment

**Acceptance Criteria:**
- [ ] Can review all payroll calculations
- [ ] Can view individual payroll items
- [ ] Can approve or reject payroll
- [ ] Can add approval comments
- [ ] System records approval with timestamp
- [ ] System prevents changes after approval
- [ ] System notifies relevant parties of approval

### 3. Payroll Reporting

#### US-PAY-006: Generate Payroll Reports
**As a** payroll administrator  
**I want to** generate payroll reports  
**So that** I can provide accurate information to stakeholders

**Acceptance Criteria:**
- [ ] Can generate payroll summary reports
- [ ] Can generate individual employee pay stubs
- [ ] Can generate tax and deduction reports
- [ ] Can export reports in various formats
- [ ] Can filter reports by date range, or employee
- [ ] System ensures data accuracy and completeness

#### US-PAY-007: Track Payroll History
**As a** payroll administrator  
**I want to** track payroll history  
**So that** I can maintain accurate records and resolve issues

**Acceptance Criteria:**
- [ ] Can view historical payroll data
- [ ] Can search payroll by employee, date, or amount
- [ ] Can compare payroll across periods
- [ ] Can track payroll trends and patterns
- [ ] Can generate historical reports
- [ ] System maintains complete payroll history

---

## Rule Engine System

### 1. Business Rule Management

#### US-RE-001: Create Business Rules
**As a** system administrator  
**I want to** create business rules  
**So that** I can automate complex payroll and scheduling logic

**Acceptance Criteria:**
- [ ] Can create rules with unique names and types
- [ ] Can assign rules to job codes, or time entry types
- [ ] Can define rule conditions using JSON
- [ ] Can define rule actions using JSON
- [ ] Can set rule priority and effective dates
- [ ] Can enable/disable rules
- [ ] System validates rule syntax and logic
- [ ] System prevents conflicting rules

#### US-RE-002: Configure Overtime Rules
**As a** payroll administrator  
**I want to** configure overtime calculation rules  
**So that** overtime is calculated correctly according to company policy

**Acceptance Criteria:**
- [ ] Can set overtime thresholds (daily, weekly, etc.)
- [ ] Can configure overtime multipliers
- [ ] Can specify which hours count toward overtime
- [ ] Can set maximum overtime hours
- [ ] Can configure holiday and weekend overtime rules
- [ ] Can set different rules for different job codes
- [ ] System applies rules consistently across all calculations

#### US-RE-003: Configure Holiday Rules
**As a** payroll administrator  
**I want to** configure holiday pay rules  
**So that** holiday pay is calculated correctly

**Acceptance Criteria:**
- [ ] Can configure holiday pay multipliers
- [ ] Can set requirements for holiday pay eligibility
- [ ] Can configure floating holiday rules
- [ ] Can set different rules for different holidays
- [ ] Can require work on holiday for pay eligibility
- [ ] System applies holiday rules during payroll processing

### 2. Rule Execution

#### US-RE-004: Execute Business Rules
**As a** system  
**I want to** execute business rules during processing  
**So that** all calculations follow company policies

**Acceptance Criteria:**
- [ ] System executes rules in priority order
- [ ] System applies rules to relevant time entries
- [ ] System records rule execution results
- [ ] System handles rule conflicts appropriately
- [ ] System provides detailed execution logs
- [ ] System can rollback rule executions if needed

#### US-RE-005: Track Rule Execution
**As a** system administrator  
**I want to** track rule execution  
**So that** I can monitor system performance and troubleshoot issues

**Acceptance Criteria:**
- [ ] Can view rule execution history
- [ ] Can see which rules were applied to which entries
- [ ] Can view execution results and calculations
- [ ] Can identify failed or problematic rules
- [ ] Can generate rule execution reports
- [ ] System maintains detailed execution logs

---

## Holiday Management System

### 1. Holiday Configuration

#### US-HOL-001: Create Holidays
**As a** system administrator  
**I want to** create and manage company holidays  
**So that** employees and payroll systems can properly handle holiday schedules

**Acceptance Criteria:**
- [ ] Can create holidays with names and dates
- [ ] Holiday will have own code like US-HOL-002 etc
- [ ] Holiday will be granted as per the job code, we can also add setting for all job codes (means for every employee)
- [ ] Holiday can be of type payed or not payed 
- [ ] Payed Holiday will take part in accruing process, like if employee takes 2 leaves, it will still give him 1.5 accrue day for 1 month and will not make it 1.20 or so
- [ ] Can mark holidays as observed or actual dates
- [ ] Can set holidays as floating (e.g., floating holiday)
- [ ] Can apply holidays to all employees or specific groups
- [ ] Can set holiday effective and expiry dates
- [ ] System validates holiday configurations
- [ ] System prevents duplicate holidays

#### US-HOL-002: Assign Holidays to Employees
**As a** system administrator  
**I want to** assign holidays to specific employees or groups  
**So that** only eligible employees receive holiday benefits

**Acceptance Criteria:**
- [ ] Can assign holidays to individual employees
- [ ] Can assign holidays to job codes
- [ ] Can set different holiday rules for different groups
- [ ] Can override individual holiday assignments
- [ ] System validates holiday assignments
- [ ] System tracks holiday eligibility

### 2. Holiday Integration

#### US-HOL-003: Integrate Holidays with Time Entries
**As a** system  
**I want to** automatically handle holiday time entries  
**So that** holiday pay is calculated correctly

**Acceptance Criteria:**
- [ ] System automatically creates holiday time entries
- [ ] System applies appropriate holiday pay rates
- [ ] System handles floating holidays
- [ ] System integrates with accrual calculations
- [ ] System prevents duplicate holiday entries
- [ ] System handles holiday scheduling conflicts

#### US-HOL-004: Manage Holiday Scheduling
**As a** scheduling manager  
**I want to** manage holiday schedules  
**So that** I can ensure proper coverage during holidays

**Acceptance Criteria:**
- [ ] Can view holiday schedules
- [ ] Can assign employees to work on holidays
- [ ] Can handle holiday shift trades
- [ ] Can manage holiday overtime
- [ ] Can track holiday coverage
- [ ] System respects holiday work rules

---

## Integration and Cross-System Features

### 1. Data Integration

#### US-INT-001: Sync Employee Data
**As a** system  
**I want to** keep employee data synchronized across all modules  
**So that** all systems have consistent information

**Acceptance Criteria:**
- [ ] System syncs employee changes across all modules
- [ ] System maintains data consistency
- [ ] System handles data conflicts appropriately
- [ ] System provides data validation
- [ ] System maintains audit trails

#### US-INT-002: Integrate with External Systems
**As a** system administrator  
**I want to** integrate with external HR and payroll systems  
**So that** data can be shared and synchronized

**Acceptance Criteria:**
- [ ] Can import employee data from external systems
- [ ] Can export payroll data to external systems
- [ ] Can sync time and attendance data
- [ ] Can handle data mapping and transformation
- [ ] Can schedule automated data transfers
- [ ] System provides error handling and logging

### 2. Reporting and Analytics

#### US-REP-001: Generate Comprehensive Reports
**As a** manager  
**I want to** generate comprehensive reports across all modules  
**So that** I can make informed business decisions

**Acceptance Criteria:**
- [ ] Can generate cross-module reports
- [ ] Can create custom report templates
- [ ] Can schedule automated report generation
- [ ] Can export reports in multiple formats
- [ ] Can drill down into report details
- [ ] System provides real-time and historical data

#### US-REP-002: Dashboard and Analytics
**As a** manager  
**I want to** view dashboards and analytics  
**So that** I can monitor system performance and key metrics

**Acceptance Criteria:**
- [ ] Can view real-time dashboards
- [ ] Can see key performance indicators
- [ ] Can track trends and patterns
- [ ] Can customize dashboard views
- [ ] Can set up alerts and notifications
- [ ] System provides interactive analytics

---

## Security and Compliance

### 1. Access Control

#### US-SEC-001: Manage User Permissions
**As a** system administrator  
**I want to** manage user permissions and access control  
**So that** only authorized users can access sensitive data

**Acceptance Criteria:**
- [ ] Can create user roles and permissions
- [ ] Can assign permissions to users
- [ ] Can control access to specific modules and data
- [ ] Can set up approval workflows
- [ ] Can track user access and activities
- [ ] System enforces permission restrictions

#### US-SEC-002: Audit Trail
**As a** system administrator  
**I want to** maintain comprehensive audit trails  
**So that** all system activities are tracked and auditable

**Acceptance Criteria:**
- [ ] System logs all user activities
- [ ] System tracks data changes and modifications
- [ ] System maintains audit trail integrity
- [ ] Can generate audit reports
- [ ] Can search audit logs
- [ ] System provides compliance reporting

### 2. Data Security

#### US-SEC-003: Data Encryption and Security
**As a** system administrator  
**I want to** ensure data security and encryption  
**So that** sensitive employee data is protected

**Acceptance Criteria:**
- [ ] System encrypts sensitive data at rest
- [ ] System encrypts data in transit
- [ ] System implements proper authentication
- [ ] System provides data backup and recovery
- [ ] System meets compliance requirements
- [ ] System provides security monitoring

---

This comprehensive set of user stories covers all aspects of the Scheduling and Time Management system as defined in the ERD. Each story includes detailed acceptance criteria to ensure complete functionality and proper integration between all system components.
