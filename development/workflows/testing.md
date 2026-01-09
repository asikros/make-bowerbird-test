# Testing

## Modifying Files

After modifying source files or test files, test everything running make clean && make check to ensure everything is working

- Review the tests to ensure that tests are simple and direct, with the suite of tests covering all the corner cases. Best if a test failure clearly indicates which statement in the source code is failing.

- When a test fails, carefully review the source code to root cause the issue and fix it by addressing the underlying issue, don't hack the code to pass the tests and don't hack the tests to pass

- If a test fails do to a side-effect from something not covered by a test, add a test.

- Repeat until the tests pass and the test coverage is excellent
