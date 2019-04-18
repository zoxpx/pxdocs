## Scheduling migrations

You can schedule a migration through a schedule policy. In the next sections, we will walk you through how to spec, validate, and display a schedule policy. Then, we will use our new schedule policy to schedule a migration.

### Schedule policies

You can use schedule policies to specify when a specific action needs to be triggered. Schedule policies do not contain any actions themselves. Also, they are not namespaced.
Storage policies are similar to storage classes where an admin is expected to create schedule policies which are then consumed by other users.

There are 4 sections in a schedule Policy spec:

* **Interval:** the interval in minutes after which the action should be triggered
* **Daily:** the time at which the action should be triggered every day
* **Weekly:** the day of the week and the time in that day when the action should be triggered
* **Monthly:** the date of the month and the time on that date when the action should be triggered

Let's look at an example of how we could spec a policy:

```text
apiVersion: stork.libopenstorage.org/v1alpha1
kind: SchedulePolicy
metadata:
  name: testpolcy
  namespace: mysql
policy:
  interval:
    intervalMinutes: 1
  daily:
    time: "10:14PM"
  weekly:
    day: "Thursday"
    time: "10:13PM"
  monthly:
    date: 14
    time: "8:05PM"
```

#### Validation

The following validations rules are defined:

* The times in the policy need to follow the time.Kitchen format, example 1:02PM or 1:02pm.
* The date of the month should be greater than 0 and less than 31. If a date doesn't exist in a month, it will roll over to the next month. For example, if the date is specified as Feb 31, it will trigger on either 2nd or 3rd March depending on if it is a leap year.
* The weekday can be specified in either long or short format, ie either "Sunday" or "Sun" are valid days.

### Displaying a policy

To display a policy, run `storkctl get` with the name of the policy as a parameter:

```text
storkctl get schedulepolicy
```

```
NAME           INTERVAL-MINUTES   DAILY     WEEKLY             MONTHLY
testpolicy     1                  10:14PM   Thursday@10:13PM   14@8:05PM
```