# Scheduling Module - Notifications List

## 📋 Table of Contents
1. [Success Notifications](#success-notifications)
2. [Error Notifications](#error-notifications)
3. [Warning Notifications](#warning-notifications)
4. [Info Notifications](#info-notifications)
5. [Validation Messages](#validation-messages)

---

## ✅ Success Notifications

### Shift Management
- **Shift saved successfully**
  - Displayed when a shift is created or updated successfully.

- **Shift deleted successfully**
  - Displayed when a shift is removed from the system.

- **Open slot added successfully**
  - Displayed when an additional open slot position is added to a shift.

- **Open slot removed successfully**
  - Displayed when an open slot position is removed from a shift.

- **Shift label assigned successfully**
  - Displayed when a label is assigned or updated for a shift.

### Employee Assignment
- **Employee scheduled successfully**
  - Displayed when an employee is successfully assigned to a shift slot.

- **Assignment ended successfully**
  - Displayed when a shift assignment is successfully ended/terminated.

- **Assignment updated successfully**
  - Displayed when assignment details (job codes, work codes, labels) are updated.

- **Assignment notes saved successfully**
  - Displayed when notes are added or updated for an assignment.

### Trade Requests
- **Trade request sent successfully**
  - Displayed when a trade request is created and sent to another employee.

- **Trade request approved successfully**
  - Displayed when a trade request is approved by the accepting employee or admin.

- **Trade request denied successfully**
  - Displayed when a trade request is denied/rejected.

- **Trade request deleted successfully**
  - Displayed when a trade request is cancelled or removed.

- **Trade request accepted successfully**
  - Displayed when an employee accepts a trade request.

### Time Off Requests
- **Time off request saved successfully**
  - Displayed when a time off request is created or updated.

- **Time off request approved successfully**
  - Displayed when a time off request is approved by an admin.

- **Time off request rejected successfully**
  - Displayed when a time off request is rejected by an admin.

- **Time off request deleted successfully**
  - Displayed when a time off request is cancelled or removed.

### Availability
- **Availability saved successfully**
  - Displayed when employee availability is updated.

- **Availability slot updated successfully**
  - Displayed when a specific availability time slot is modified.

### Settings & Configuration
- **Settings saved successfully**
  - Displayed when scheduling settings or trade board settings are saved.

- **Daily view layout saved successfully**
  - Displayed when the staff scheduling daily view layout is saved.

- **Column added successfully**
  - Displayed when a new column is added to the daily view layout.

- **Column deleted successfully**
  - Displayed when a column is removed from the daily view layout.

### Employee Assignments (Job Codes, Work Codes, Labels)
- **Employee job code assignment saved successfully**
  - Displayed when an employee job code assignment is created or updated.

- **Employee work code assignment saved successfully**
  - Displayed when an employee work code assignment is created or updated.

- **Employee label assignment saved successfully**
  - Displayed when an employee label assignment is created or updated.

---

## ❌ Error Notifications

### General Errors
- **An error occurred while processing your request**
  - Generic error message for unexpected failures.

- **Error loading data**
  - Displayed when data fails to load from the server.

- **Network error. Please check your connection**
  - Displayed when there's a network connectivity issue.

- **Session expired. Please log in again**
  - Displayed when user session has expired.

### Shift Management Errors
- **Error saving shift**
  - Displayed when shift save operation fails.

- **Error deleting shift**
  - Displayed when shift deletion fails.

- **Error loading shifts**
  - Displayed when shift data cannot be loaded.

- **Error updating slot positions**
  - Displayed when adding or removing open slots fails.

- **Failed to add open slot**
  - Displayed when adding an open slot position fails.

- **Failed to remove open slot**
  - Displayed when removing an open slot position fails.

### Employee Assignment Errors
- **Error scheduling employee**
  - Displayed when assigning an employee to a shift fails.

- **Error ending assignment**
  - Displayed when ending an assignment operation fails.

- **Assignment data not available**
  - Displayed when assignment information is missing or unavailable.

- **Error updating assignment**
  - Displayed when assignment update operation fails.

- **Error loading assignment details**
  - Displayed when assignment information cannot be loaded.

### Trade Request Errors
- **Error sending trade request**
  - Displayed when creating a trade request fails.

- **Error loading trade requests**
  - Displayed when trade request data cannot be loaded.

- **Error approving trade request**
  - Displayed when trade approval operation fails.

- **Error denying trade request**
  - Displayed when trade denial operation fails.

- **Error deleting trade request**
  - Displayed when trade deletion operation fails.

- **Error loading trade request details**
  - Displayed when trade request information cannot be loaded.

### Time Off Request Errors
- **Error saving time off request**
  - Displayed when time off request save operation fails.

- **Error loading time off requests**
  - Displayed when time off request data cannot be loaded.

- **Error approving time off request**
  - Displayed when time off approval operation fails.

- **Error rejecting time off request**
  - Displayed when time off rejection operation fails.

- **Error deleting time off request**
  - Displayed when time off deletion operation fails.

- **Time off request not found**
  - Displayed when requested time off data is not available.

### Availability Errors
- **Error loading availability data**
  - Displayed when employee availability data cannot be loaded.

- **Error saving availability**
  - Displayed when availability save operation fails.

- **Error loading users list**
  - Displayed when employee/user list cannot be loaded.

### Configuration Errors
- **Error loading system settings**
  - Displayed when system settings cannot be loaded.

- **Error saving settings**
  - Displayed when settings save operation fails.

- **Error loading daily view layout**
  - Displayed when daily view configuration cannot be loaded.

- **Error deleting column**
  - Displayed when column deletion fails.

- **No layout found. Please setup rows/columns first**
  - Displayed when trying to save daily view without a layout configuration.

### Validation & Conflict Errors
- **Scheduling conflict detected**
  - Displayed when there's a conflict with existing assignments.

- **Availability conflict detected**
  - Displayed when employee availability conflicts with the requested schedule.

- **Time off conflict detected**
  - Displayed when requested time overlaps with existing time off.

- **Trade conflict detected**
  - Displayed when a trade request conflicts with existing assignments or trades.

- **Job code conflict detected**
  - Displayed when employee doesn't have required job codes.

- **Work code conflict detected**
  - Displayed when employee doesn't have required work codes.

---

## ⚠️ Warning Notifications

### Permission Warnings
- **Self-scheduling is not enabled for this shift**
  - Displayed when user tries to schedule themselves but self-scheduling is disabled.

- **You don't have permission to perform this action**
  - Displayed when user lacks required permissions.

### Validation Warnings
- **Please select an employee first**
  - Displayed when employee selection is required but not provided.

- **Please select a user first**
  - Displayed when user selection is required but not provided.

- **Date cannot be in the past**
  - Displayed when user selects a past date for scheduling or ending assignment.

- **Cannot edit past slots**
  - Displayed when user tries to modify availability or assignments in the past.

- **Cannot schedule in past or ongoing slot**
  - Displayed when user tries to assign employee to a slot that has already started or passed.

- **This slot has already started. Please select a future date**
  - Displayed when trying to end an assignment for a slot that has already begun today.

- **Future dates are not allowed for one-time assignments. Please select today**
  - Displayed when trying to end a non-recurring assignment with a future date.

- **End date and time must be greater than or equal to the assignment start date and time**
  - Displayed when selected end date/time is before the assignment start.

- **A trade is present with a date greater than the selected date. Assignment cannot be ended**
  - Displayed when trying to end an assignment before an active trade date.

- **A trade is present for this assignment. Updation of assignment before the trade date cannot be done**
  - Displayed when trying to modify an assignment that has an active trade.

### Trade Warnings
- **A trade is present for this assignment. The assignment cannot be ended before the trade date. If the trade date is before your selected date, the assignment can be ended**
  - Displayed in delete assignment dialog when a trade exists.

- **Trade request cannot be processed due to conflicts**
  - Displayed when trade request has validation or conflict issues.

### Data Warnings
- **No shifts found for the selected criteria**
  - Displayed when no shifts match the current filters.

- **No employees found matching your search**
  - Displayed when employee search returns no results.

- **No trade requests available**
  - Displayed when there are no trade requests to display.

- **No time off requests available**
  - Displayed when there are no time off requests to display.

### Configuration Warnings
- **Please setup rows/columns first before saving**
  - Displayed when trying to save daily view without proper layout.

- **Minimum positions cannot be less than filled positions**
  - Displayed when trying to reduce minimum positions below current assignments.

---

## ℹ️ Info Notifications

### General Information
- **Loading shifts...**
  - Displayed during data loading operations.

- **Processing your request...**
  - Displayed during async operations.

- **Auto-saved successfully**
  - Displayed when automatic save operations complete (may be silent).

### Assignment Information
- **This is a one-time assignment**
  - Displayed in delete assignment dialog for non-recurring assignments.

- **Current End Type: [Never/OnDate/AfterOccurrences]**
  - Displayed in delete assignment dialog showing current assignment end configuration.

### Trade Information
- **Trade request is pending approval**
  - Displayed when a trade request is awaiting response.

- **Trade request has been accepted**
  - Displayed when a trade request is accepted.

- **Trade request has been denied**
  - Displayed when a trade request is denied.

### Time Off Information
- **Time off request is pending approval**
  - Displayed when a time off request is awaiting admin approval.

- **Time off request has been approved**
  - Displayed when a time off request is approved.

- **Time off request has been rejected**
  - Displayed when a time off request is rejected.

### Availability Information
- **Availability has been updated**
  - Displayed when availability changes are saved.

- **You have unsaved changes**
  - Displayed when there are pending unsaved modifications.

---

## 🔍 Validation Messages (Form Errors)

### Date/Time Validation
- **Date is required**
  - Displayed when date field is empty.

- **Time is required**
  - Displayed when time field is empty.

- **Invalid date format**
  - Displayed when date format is incorrect.

- **Invalid time format**
  - Displayed when time format is incorrect.

- **Date cannot be in the past**
  - Displayed when past date is selected.

- **Time cannot be in the past for today's date**
  - Displayed when past time is selected for today.

- **End date must be after start date**
  - Displayed when end date is before start date.

- **End time must be after start time**
  - Displayed when end time is before start time.

### Assignment Validation
- **Employee is required**
  - Displayed when employee selection is missing.

- **Shift is required**
  - Displayed when shift selection is missing.

- **Job code is required**
  - Displayed when required job code is not selected.

- **Work code is required**
  - Displayed when required work code is not selected.

- **Assignment end date/time must be greater than or equal to shift start date/time**
  - Displayed when assignment end is before shift start.

### Trade Validation
- **Trading date is required**
  - Displayed when trading date is not provided.

- **Accepting date is required**
  - Displayed when accepting date is not provided.

- **Trading employee is required**
  - Displayed when trading employee is not selected.

- **Accepting employee is required**
  - Displayed when accepting employee is not selected.

- **Cannot trade with yourself**
  - Displayed when user tries to create a trade with themselves.

### Time Off Validation
- **Start date is required**
  - Displayed when time off start date is missing.

- **End date is required**
  - Displayed when time off end date is missing.

- **Time off code is required**
  - Displayed when time off code is not selected.

- **Start date cannot be after end date**
  - Displayed when time off dates are invalid.

### General Validation
- **This field is required**
  - Generic required field message.

- **Invalid input format**
  - Displayed when input format is incorrect.

- **Maximum length exceeded**
  - Displayed when input exceeds maximum allowed length.

- **Minimum length not met**
  - Displayed when input is below minimum required length.

---

## 📝 Notes

### Notification Types
- **Success**: Green/positive notifications for successful operations
- **Error**: Red/danger notifications for failures and errors
- **Warning**: Yellow/warning notifications for validation issues and warnings
- **Info**: Blue/info notifications for informational messages

### Notification Positions
- **Bottom Right**: Default position for most notifications
- **Bottom Left**: Alternative position for specific use cases
- **Top Right**: For critical or important notifications
- **Top Left**: For less critical notifications

### Notification Duration
- **Success**: 3-5 seconds
- **Error**: 5-7 seconds (longer for critical errors)
- **Warning**: 4-6 seconds
- **Info**: 3-4 seconds

---

## 🔄 Dynamic Notification Messages

Some notifications include dynamic content:
- Employee names
- Shift names
- Dates and times
- Error codes or IDs
- Conflict details
- Trade request IDs
- Assignment IDs

Example: "Employee [John Doe] scheduled successfully for [Morning Shift] on [2025-01-15]"

