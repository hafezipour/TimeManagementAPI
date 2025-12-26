# Scheduling Module - Email Notifications List

## 📧 Assignment Notifications

### Employee Assigned to Shift
- **Subject**: `You have been assigned to [Shift Name] on [Date]`
- **Recipients**: Assigned Employee
- **When**: Immediately after assignment is created
- **Content**: 
  - Shift name, date, start time, end time
  - Location
  - Job codes and work codes (if applicable)
  - Assignment notes (if any)
  - Link to view schedule details
- **Priority**: High

### Assignment Modified
- **Subject**: `Your assignment has been updated - [Shift Name] on [Date]`
- **Recipients**: Assigned Employee
- **When**: When assignment details are modified (time, job codes, work codes, notes)
- **Content**:
  - Previous assignment details
  - Updated assignment details
  - Reason for change (if provided)
  - Link to view schedule details
- **Priority**: Medium

### Assignment Ended/Cancelled
- **Subject**: `Your assignment has been ended - [Shift Name] on [Date]`
- **Recipients**: Assigned Employee
- **When**: When assignment is ended or cancelled
- **Content**:
  - Shift name, date, original time
  - End date/time
  - Reason for ending (if provided)
  - Link to view schedule details
- **Priority**: High

### Assignment Removed by Admin
- **Subject**: `Your assignment has been removed - [Shift Name] on [Date]`
- **Recipients**: Assigned Employee
- **When**: When admin removes an assignment
- **Content**:
  - Shift name, date, time
  - Reason for removal (if provided)
  - Admin contact information
  - Link to view schedule details
- **Priority**: High

### Open Slot Available Notification
- **Subject**: `New open slot available - [Shift Name] on [Date]`
- **Recipients**: Eligible Employees (based on job codes, work codes, availability)
- **When**: When a new open slot is created or becomes available
- **Content**:
  - Shift name, date, start time, end time
  - Location
  - Required qualifications
  - Deadline to claim (if applicable)
  - Link to claim/open slot
- **Priority**: Medium
- **Note**: Only if self-scheduling is enabled

---

## 🔄 Trade Request Notifications

### Trade Request Received
- **Subject**: `New trade request from [Employee Name] - [Shift Name] on [Date]`
- **Recipients**: Requested Employee (accepting employee)
- **When**: When a trade request is created
- **Content**:
  - Trading employee name and contact
  - Shift details (name, date, time, location)
  - Trading date (date they want to trade)
  - Accepting date (date they want to accept)
  - Trade type (swap or one-way)
  - Message from trading employee (if provided)
  - Deadline to respond (if applicable)
  - Link to approve/deny trade request
- **Priority**: High

### Trade Request Approved
- **Subject**: `Trade request approved - [Shift Name] on [Date]`
- **Recipients**: 
  - Trading Employee (original requestor)
  - Accepting Employee (who approved)
  - Admins (if admin approval required)
- **When**: When trade request is approved
- **Content**:
  - Shift details for both employees
  - Confirmed trading date and accepting date
  - Next steps
  - Link to view updated schedule
- **Priority**: High

### Trade Request Denied
- **Subject**: `Trade request denied - [Shift Name] on [Date]`
- **Recipients**: Trading Employee (original requestor)
- **When**: When trade request is denied
- **Content**:
  - Shift details
  - Denial reason (if provided)
  - Alternative options or suggestions
  - Link to view schedule
- **Priority**: Medium

### Trade Request Cancelled
- **Subject**: `Trade request cancelled - [Shift Name] on [Date]`
- **Recipients**: 
  - Accepting Employee (if request was pending)
  - Admins (if admin approval was pending)
- **When**: When trade request is cancelled by trading employee
- **Content**:
  - Shift details
  - Cancellation reason (if provided)
  - Link to view schedule
- **Priority**: Low

### Trade Request Expiring Soon
- **Subject**: `Reminder: Trade request expiring soon - [Shift Name]`
- **Recipients**: Accepting Employee
- **When**: 24 hours before trade request expires (if expiration is set)
- **Content**:
  - Shift details
  - Expiration date/time
  - Link to approve/deny trade request
- **Priority**: Medium

### Trade Request Auto-Expired
- **Subject**: `Trade request expired - [Shift Name] on [Date]`
- **Recipients**: 
  - Trading Employee
  - Accepting Employee
- **When**: When trade request expires without response
- **Content**:
  - Shift details
  - Expiration date/time
  - Link to view schedule
- **Priority**: Low

---

## 🏖️ Time Off Request Notifications

### Time Off Request Submitted
- **Subject**: `Time off request submitted - [Start Date] to [End Date]`
- **Recipients**: 
  - Requesting Employee
  - Assigned Approvers/Admins
- **When**: When time off request is created
- **Content**:
  - Request dates and times
  - Time off code/type
  - Reason (if provided)
  - Status (pending approval)
  - Link to view request details
- **Priority**: Medium

### Time Off Request Approved
- **Subject**: `Time off request approved - [Start Date] to [End Date]`
- **Recipients**: Requesting Employee
- **When**: When time off request is approved
- **Content**:
  - Approved dates and times
  - Time off code/type
  - Approver name and comments (if any)
  - Link to view schedule
- **Priority**: High

### Time Off Request Rejected
- **Subject**: `Time off request rejected - [Start Date] to [End Date]`
- **Recipients**: Requesting Employee
- **When**: When time off request is rejected
- **Content**:
  - Requested dates and times
  - Rejection reason
  - Approver name and comments
  - Alternative suggestions (if any)
  - Link to submit new request
- **Priority**: High

### Time Off Request Cancelled
- **Subject**: `Time off request cancelled - [Start Date] to [End Date]`
- **Recipients**: Assigned Approvers/Admins
- **When**: When employee cancels their time off request
- **Content**:
  - Requested dates and times
  - Cancellation reason (if provided)
  - Link to view requests
- **Priority**: Low

### Time Off Request Pending Approval Reminder
- **Subject**: `Reminder: Time off request pending approval - [Start Date] to [End Date]`
- **Recipients**: Assigned Approvers/Admins
- **When**: Daily reminder if request is pending for more than 2 days
- **Content**:
  - Request details
  - Days pending
  - Employee name and contact
  - Link to approve/reject request
- **Priority**: Medium

## 📍 Availability Notifications

### Availability Updated
- **Subject**: `Your availability has been updated`
- **Recipients**: Employee
- **When**: When employee availability is modified (by employee or admin)
- **Content**:
  - Updated availability periods
  - Changes made
  - Effective dates
  - Link to view/edit availability
- **Priority**: Low

### Availability Conflict Detected
- **Subject**: `Availability conflict detected - [Shift Name] on [Date]`
- **Recipients**: 
  - Assigned Employee
  - Admins/Managers
- **When**: When an assignment conflicts with employee's availability
- **Content**:
  - Shift details
  - Conflict details (which availability period conflicts)
  - Assignment details
  - Actions required
  - Link to update availability or contact admin
- **Priority**: High

---

### Upcoming Shift Reminder
- **Subject**: `Reminder: You have a shift tomorrow - [Shift Name]`
- **Recipients**: Assigned Employees
- **When**: 24 hours before shift start time
- **Content**:
  - Shift name, date, start time, end time
  - Location
  - Required items/preparation
  - Contact information
  - Link to view shift details
- **Priority**: Medium

### Shift Starting Soon Reminder
- **Subject**: `Reminder: Your shift starts in [X] hours - [Shift Name]`
- **Recipients**: Assigned Employees
- **When**: 2-4 hours before shift start time (configurable)
- **Content**:
  - Shift name, date, start time, end time
  - Location
  - Check-in instructions (if any)
  - Link to view shift details
- **Priority**: High

---

## ⏰ Reminder Notifications

### Trade Request Response Due Soon
- **Subject**: `Action required: Trade request response due soon`
- **Recipients**: Employees with pending trade requests
- **When**: 24 hours before trade request expires
- **Content**:
  - Trade request details
  - Expiration date/time
  - Link to approve/deny
- **Priority**: Medium

### Time Off Request Approval Due
- **Subject**: `Action required: Time off request pending your approval`
- **Recipients**: Approvers/Admins
- **When**: Daily reminder for requests pending more than 1 day
- **Content**:
  - Request details
  - Employee information
  - Days pending
  - Link to approve/reject
- **Priority**: Medium

### Availability Update Reminder
- **Subject**: `Reminder: Update your availability`
- **Recipients**: Employees with outdated availability
- **When**: Monthly reminder if availability hasn't been updated in 30+ days
- **Content**:
  - Current availability summary
  - Last updated date
  - Link to update availability
- **Priority**: Lowest

### Trade Request Requires Approval
- **Subject**: `Trade request requires admin approval - [Shift Name]`
- **Recipients**: Admins/Managers
- **When**: When a trade request requires admin approval (based on settings)
- **Content**:
  - Trade request details
  - Trading and accepting employees
  - Trade dates
  - Link to approve/reject
- **Priority**: Medium

### Open Slot Unfilled Alert
- **Subject**: `Alert: Unfilled open slot - [Shift Name] on [Date]`
- **Recipients**: Admins/Managers
- **When**: 24-48 hours before shift if open slot remains unfilled
- **Content**:
  - Shift details
  - Number of open slots
  - Eligible employees (if any)
  - Link to assign employee
- **Priority**: High

### Minimum Positions Not Met
- **Subject**: `Alert: Minimum positions not met - [Shift Name] on [Date]`
- **Recipients**: Admins/Managers
- **When**: When assigned employees are less than minimum required positions
- **Content**:
  - Shift details
  - Minimum positions required
  - Current assignments count
  - Number of open slots needed
  - Link to assign employees
- **Priority**: High

### Schedule Approval Required
- **Subject**: `Schedule approval required - [Period]`
- **Recipients**: Approvers/Admins
- **When**: When a schedule period requires approval before publishing
- **Content**:
  - Schedule period
  - Summary of assignments
  - Issues or conflicts (if any)
  - Link to review and approve schedule
- **Priority**: Medium

### Employee Self-Scheduling Activity
- **Subject**: `Employee self-scheduled - [Shift Name] on [Date]`
- **Recipients**: Admins/Managers (if admin approval required for self-scheduling)
- **When**: When an employee schedules themselves (if approval required)
- **Content**:
  - Employee name
  - Shift details
  - Link to approve/reject assignment
- **Priority**: Medium

### Bulk Assignment Completed
- **Subject**: `Bulk assignment completed - [Period]`
- **Recipients**: Admins/Managers who performed bulk assignment
- **When**: When bulk assignment operation completes
- **Content**:
  - Number of assignments created
  - Number of conflicts detected
  - Summary of assignments
  - Link to view schedule
- **Priority**: Low
