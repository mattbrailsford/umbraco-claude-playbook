---
description: A DB lookup on every front-end render instead of a cached value cleared on save. From umbraco/Umbraco.Forms.Issues#1283.
tags: [umbraco-performance, should-trigger, real-bug]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

My Umbraco 17 package renders a signup form on front-end pages through this view
component. Before rendering, it checks whether the form has any consent step, because then
it shows a checkbox. Review it.

```csharp
public class SignupFormViewComponent : ViewComponent
{
    private readonly IFormStepService _stepService; // reads FormSteps from the database

    public SignupFormViewComponent(IFormStepService stepService) => _stepService = stepService;

    public async Task<IViewComponentResult> InvokeAsync(Guid formKey)
    {
        // Loads every step for the form and deserializes its JSON settings.
        var steps = await _stepService.GetStepsForFormAsync(formKey);
        var needsConsent = steps.Any(s => s.Settings.RequiresConsent);
        return View(new SignupFormModel(formKey, needsConsent));
    }
}
```
