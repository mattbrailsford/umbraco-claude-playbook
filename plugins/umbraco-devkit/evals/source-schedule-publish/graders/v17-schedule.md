---
type: llm
weight: 2
focus: trace
---
PASS if the code written in this run calls IContentPublishingService.PublishAsync(key,
cultures, userKey) where cultures holds a CulturePublishScheduleModel with Culture null (or
"*") for invariant content and Schedule set to a ContentScheduleModel whose PublishDate is a
DateTimeOffset, passes a Guid user key (Constants.Security.SuperUserKey), and checks the
returned Attempt.

FAIL if it uses a method or model that doesn't exist in 17.6 with that shape (for example
a ContentScheduleCollection passed to PublishAsync, a DateTime PublishDate, an int user id,
or a SchedulePublishAsync method), or doesn't use IContentPublishingService.
