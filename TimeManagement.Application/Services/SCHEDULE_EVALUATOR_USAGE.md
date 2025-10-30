# Schedule Evaluator - Simple Usage Guide

## The Concept

You give it **ONE DATE** → It tells you **TRUE or FALSE**

That's it. No complexity.

## The Method

```csharp
bool IsDateValid(ScheduleResponse schedule, DateTime date)
```

## How It Works

### Example: Weekly Schedule with Thursday

**Schedule Setup:**
- Start: Nov 1, 2024 (Friday)
- Type: Weekly
- Days: Thursday
- Repeat: Every week

**Question:** Is **November 7, 2024 (Thursday)** valid?

**Answer:**
1. ✓ Is Nov 7 after start date (Nov 1)? YES
2. ✓ Is Nov 7 a Thursday? YES
3. ✓ Is Thursday in the schedule frequency? YES
4. ✓ Are we in the right week cycle? YES (every 1 week)
5. **Result: TRUE** ✅

**Question:** Is **November 8, 2024 (Friday)** valid?

**Answer:**
1. ✓ Is Nov 8 after start date? YES
2. ✓ Is Nov 8 a Thursday? NO ❌
3. **Result: FALSE** ❌

## All Schedule Types

### 1. DoesNotRepeat
- Valid ONLY on the exact start date
- Example: Start Nov 15 → Only Nov 15 is valid

### 2. Daily
- Valid every N days from start
- Example: Start Nov 1, repeat every 2 days → Nov 1, 3, 5, 7, 9...

### 3. Weekly
- Valid on selected weekdays (Sun=0, Mon=1, ..., Sat=6)
- Respects week cycle (every 1 week, every 2 weeks, etc.)
- Example: Thursday every week → All Thursdays after start

### 4. Monthly
- Valid on selected days of month (1-31)
- Respects month cycle (every 1 month, every 3 months, etc.)
- Example: 1st and 15th every month → Those dates each month

### 5. DaysOnOff
- Pattern of X days on, Y days off
- Example: 3 on, 2 off → Days 0-2 ON, 3-4 OFF, 5-7 ON, 8-9 OFF...

## Usage in Your Code

```csharp
// Inject or create
var evaluator = new ScheduleEvaluator();

// Get schedule from database
var schedule = shift.Schedules; // ScheduleResponse object

// Loop through calendar days
for (int i = 0; i < numberOfDays; i++)
{
    var currentDate = startDate.AddDays(i);
    
    // Simple check
    if (evaluator.IsDateValid(schedule, currentDate))
    {
        // This shift occurs on currentDate!
        // Use schedule.StartTime and schedule.EndTime for shift times
        Console.WriteLine($"Shift occurs on {currentDate:yyyy-MM-dd}");
        Console.WriteLine($"Time: {schedule.StartTime} to {schedule.EndTime}");
    }
}
```

## End Types

### Never
- Schedule continues forever

### OnDate
- Schedule ends on `ValidUntil` date
- After that date: FALSE

### AfterOccurrences
- Schedule ends after `MaxOccurrences` times
- After 5th occurrence: FALSE

## Testing

Run the examples to verify all schedule types:

```csharp
var examples = new ScheduleEvaluatorExamples();
examples.RunAllExamples();
```

Output shows ✓ PASS or ✗ FAIL for each test case.

## Summary

- **Input**: One date
- **Output**: True/False
- **Use**: StartTime/EndTime from ScheduleResponse
- **Simple**: No range calculations, no complexity
- **Fast**: Optimized for single-date checks

