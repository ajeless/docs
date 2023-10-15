# Test Design Techniques

## 1. Boundary Value Analysis (BVA)

### Description:
Boundary Value Analysis is a black box test design technique used to identify errors at boundaries rather than finding those that exist in the center of the input domain. It's based on the principle that bugs often reside at the boundaries of defined input ranges.

### Context of Use:
- When the system behavior is different across boundaries.
- For functions that accept a range of values.

### Example:
If a function accepts an age value between 18 and 60:
- **Valid Boundary Values**: 18, 60
- **Invalid Boundary Values**: 17, 61

## 2. Equivalence Partitioning (EP)

### Description:
Equivalence Partitioning is a test case design technique that divides the input domain of a program into classes of data from which test cases can be derived. Each partition/class should behave in the same manner, meaning if a single test case from a partition class passes, all the test cases from that class should pass.

### Context of Use:
- When input data can be divided into different classes.
- For functions that have a large set of possible input values.

### Example:
For a function that accepts a discount percentage between 1% and 10%:
- **Valid Class**: Any value between 1% and 10%
- **Invalid Classes**: Values below 1% and values above 10%

## 3. Decision Table Testing

### Description:
Decision Table Testing is a systematic approach to multi-condition testing. It's useful for functions that have multiple input combinations and corresponding outputs. A decision table represents combinations of inputs to determine possible outputs.

### Context of Use:
- When system behavior is influenced by different combinations of inputs.
- For complex business rules that involve multiple conditions.

### Example:
Consider a system that determines if a person is eligible for a loan based on their age and credit score:

| Age > 18 | Credit Score > 650 | Loan Approval |
|----------|--------------------|---------------|
| Yes      | Yes                | Yes           |
| Yes      | No                 | No            |
| No       | Yes                | No            |
| No       | No                 | No            |

## 4. State Transition Testing

### Description:
Used when software behavior changes from one state to another following particular actions. It involves creating a state diagram and then designing test cases based on the transitions between states.

### Context of Use:
- For systems that have different states and transitions.
- Especially useful for systems like finite state machines.

### Example:
Consider a simple door lock system with states: LOCKED and UNLOCKED. The transitions are LOCK and UNLOCK.

| Current State | Action  | Next State |
|---------------|---------|------------|
| LOCKED        | UNLOCK  | UNLOCKED   |
| UNLOCKED      | LOCK    | LOCKED     |

## 5. Use Case Testing

### Description:
Based on the use cases provided by the business team or stakeholders. Each use case defines a sequence of actions, typically including both the main scenario and alternative scenarios.

### Context of Use:
- For systems that are designed based on user requirements or user stories.
- Useful to ensure all user scenarios are covered.

### Example:
A use case for an ATM might include:
- Main Scenario: User inserts card, enters PIN, withdraws cash, and takes the card.
- Alternative Scenario: User enters incorrect PIN three times, and the card is retained.

## 6. Error Guessing

### Description:
Relies on the tester's experience and intuition to guess where defects might be present. It's less systematic but can be effective, especially when combined with other techniques.

### Context of Use:
- When testers have deep knowledge of the system or domain.
- Useful for finding edge cases or rare scenarios.

### Example:
A tester might guess that a web application is vulnerable to SQL injection in its search functionality and would test that specific functionality with malicious inputs.

## 7. Pairwise (All-Pairs) Testing

### Description:
A combinatorial testing technique where test cases are designed to cover all possible combinations of each pair of input parameters. Useful when the number of input parameters is large, but testing all combinations would be impractical.

### Context of Use:
- For systems with multiple input parameters.
- When exhaustive testing is not feasible due to time or resource constraints.

### Example:
For a system that accepts three inputs: Color (Red, Blue), Size (Small, Large), and Shape (Circle, Square), instead of testing all 8 combinations, you'd test only the combinations that cover all pairs, reducing the number of tests.

## 8. Exploratory Testing

### Description:
Testers explore the application without predefined test cases or specific test objectives. It's a more ad-hoc approach, relying on the tester's skills and intuition.

### Context of Use:
- When there's limited documentation or requirements.
- Useful in agile environments or when immediate feedback is needed.

### Example:
A tester is given a new feature in a software application and is asked to explore it and report any issues, without any specific test cases to follow.

## 9. Cause-Effect Graphing

### Description:
A graphical representation of inputs (causes) and the outputs (effects). It's used to derive test cases representing all possible causes and their effects.

### Context of Use:
- For systems with clear input-output relationships.
- Useful for complex systems where visual representation aids in understanding.

### Example:
For a system that turns on a light based on two switches, the cause-effect graph would represent the states of the switches (ON/OFF) and the effect on the light (ON/OFF).

## 10. Random Testing (or Monkey Testing)

### Description:
Involves testing the system by providing random inputs to observe if the system fails. It's less systematic and more about trying to "break" the system in unexpected ways.

### Context of Use:
- For robustness testing or stress testing.
- When the goal is to find unexpected or rare issues.

### Example:
Randomly clicking on different parts of a web application or entering random data into input fields to see if any unexpected errors occur.

---

## Comparison and Contrast:

- **BVA, EP, and Decision Table Testing** are systematic and structured techniques that are based on the requirements or specifications of the system. They are best suited for situations where clear input-output relationships are defined.

- **State Transition and Use Case Testing** are scenario-based techniques that focus on the behavior of the system and its interactions.

- **Error Guessing and Exploratory Testing** are more ad-hoc and rely on the tester's intuition and experience. They are less structured but can uncover defects that structured techniques might miss.

- **Pairwise Testing and Cause-Effect Graphing** are combinatorial techniques that aim to reduce the number of test cases while maximizing coverage.

- **Random Testing** is a less systematic approach that aims to uncover unexpected defects by "stressing" the system.

---

## When to Use Together and Separately:

- **BVA and EP** can often be used together, especially when defining the boundaries of equivalence partitions.

- **Decision Table Testing** can be combined with **State Transition Testing** for systems that have multiple states and conditions affecting transitions.

- **Use Case Testing** can be supplemented with **Exploratory Testing** to cover scenarios that
