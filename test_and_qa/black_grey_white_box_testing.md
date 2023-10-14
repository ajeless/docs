# Testing Techniques: Black Box, Grey Box, and White Box

## 1. Black Box Testing
**Definition:** Black box testing is a software testing method where the internal structure/design/implementation of the item being tested is not known to the tester. It focuses on testing the software's functionality.

**Examples:**
- **Equivalence Partitioning:** Dividing the input data of a software unit into partitions of equivalent data from which test cases can be derived.
- **Boundary Value Analysis:** Testing the software with input values at the boundary limits.
- **Decision Table Testing:** Testing the software's behavior for different input combinations. This is particularly useful when the software's behavior is different for different inputs.
- **State Transition Testing:** Testing the software's behavior for different states and transitions between those states.

## 2. Grey Box Testing
**Definition:** Grey box testing is a software testing method that combines both black box and white box testing techniques. The tester has partial knowledge of the internal workings of the software.

**Examples:**
- **Matrix Testing:** Identifying all the variables of an application and then testing them in pairs.
- **Regression Testing:** Ensuring that new changes in the software have not affected the existing functionalities.
- **Pattern Testing:** Based on the predefined patterns, the software is tested.
- **Orthogonal Array Testing:** It's a systematic, statistical way of testing which involves pair-wise testing.

## 3. White Box Testing (AKA: Glass Box Testing)
**Definition:** White box testing is a software testing method where the internal structure/design/implementation of the item being tested is known to the tester. It focuses on checking the internal logic of the software.

**Examples:**
- **Statement Coverage:** Ensuring each statement in the software is executed at least once.
- **Branch Coverage:** Ensuring each branch (decision) in the software is executed at least once.
- **Path Coverage:** Ensuring all paths in the software are executed at least once.
- **Loop Testing:** Testing the loops in the software to ensure they work as expected.

