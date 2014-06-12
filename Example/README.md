# TWTValidationExample

TWTValidationExample is a simple iOS app showing a common use-case for TWTValidation. In this app we have a simple form requiring an email, age and password. Using TWTValidation, the app disables the submit button on the form until all fields are correctly filled out.

## Implementation

### KVC

Through key-value coding we can make our form validation virtually effortless. Using `TWTKeyValueCodingValidator` we give it the Keys to observe `[NSSet setWithObjects:@"emailAddress", @"age", @"password", nil]`. 

### Validators

Now that we have assigned the Keys of the properties we want to validate, we need to assign our validators to each value. `TWTKeyValueCodingValidator` will check to see if you have implemented `+ (NSSet *)twt_validatorsFor{KEY}` where `{KEY}` is a Key you have assigned to the validator.

So for `emailAddress` we want to validate that it's between 3 characters and 99 characters long and that it has an @ symbol. So we implement the following class method.

```
+ (NSSet *)twt_validatorsForEmailAddress
{
    return [NSSet setWithObjects:[TWTStringValidator stringValidatorWithMinimumLength:3 maximumLength:99],
            [TWTStringValidator stringValidatorWithRegularExpression:[NSRegularExpression regularExpressionWithPattern:@".+@.+" options:0 error:nil] options:0],
            nil];
}
```
### KVO

The next step is to know when the form becomes valid and enable the submit button. To do this we set up a key-value observer for ``formValid`` with a target of ``formValidDidChange``. To simplify this a bit we used the very handy ``TWTKeyValueObserver`` from [Toast](https://github.com/twotoasters/Toast). This target simply checks if the form reports as valid and updates the submit button accordingly.

```
- (void)formValidDidChange
{
    self.doneButton.enabled = [self isFormValid];
}
```

We want formValid to update whenever any of our form values change. To do this we implement ``+ (NSSet *)keyPathsForValuesAffectingFormValid`` and return the Keys of the form values. This tells KVO which properties can cause ``formValid`` to change.

Then in ``formValid`` we want to make sure it reports the correct status of the form's validity. To do this we implement ``- (BOOL)isFormValid`` and return ``[self.formValidator validateValue:self error:&error]``.

