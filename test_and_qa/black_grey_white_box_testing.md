# Testing Techniques: Black Box, Grey Box, and White Box

## Black Box Testing
**Definition:** Black box testing is a software testing method where the tester does not have knowledge of the internal structure/design/implementation of the item being tested. It focuses solely on testing the software's functionality based on its requirements.

**Examples:**
- ***Equivalence Partitioning:*** Dividing the input data of a software unit into partitions of equivalent data from which test cases can be derived. A black box testing technique that divides the input domain of a program into classes of data from which test cases can be derived. It aims to reduce the number of test cases while maximizing coverage.
  - **Concrete Example:** If a software accepts a range of values between 1 and 100, both inclusive, then one can derive three equivalence classes: Less than 1, between 1 and 100, and greater than 100.
  
- ***Boundary Value Analysis:*** Testing the software with input values at the boundary limits. Focuses on the values at the boundaries of the input domain. It's based on the principle that errors often occur at the boundaries.
  - **Concrete Example:** For a form that accepts age between 18 and 65 years, the bounds to be checked are 18 and 65. Additionally, test with values like 17, 66, and some within the range like 25, 49, and 63.
  
- ***Decision Table Testing:*** Testing the software's behavior for different input combinations. A systematic way of representing complex business rules in a table format to identify test cases.
  - **Concrete Example:** For a software that calculates discounts based on age and membership status, a decision table can be created to test combinations like "Age > 60 & Member", "Age < 60 & Not a Member", etc.
  
- ***State Transition Testing:*** Testing the software's behavior for different states and transitions between those states. Focuses on testing the transitions between different states that an application can be in.
  - **Concrete Example:** For an online shopping cart, states can be "Empty", "Items Added", and "Purchased". Test transitions like "Empty" to "Items Added", "Items Added" to "Purchased", etc.

## Grey Box Testing
**Definition:** Grey box testing is a software testing method that combines both black box and white box testing techniques. The tester has partial knowledge of the internal workings of the software.

**Examples:**
- ***Matrix Testing:*** Identifying all the variables of an application and then testing them in pairs. A method where all the variables of an application are identified and then tested in pairs to ensure all combinations are covered.
  - **Concrete Example:** For a website that has different user roles (Admin, User, Guest) and actions (Read, Write, Delete), test combinations like "Admin-Read", "User-Write", "Guest-Delete", etc.
  
- ***Regression Testing:*** Ensuring that new changes in the software have not affected the existing functionalities. Ensures that recent changes in the code have not adversely impacted existing features.
  - **Concrete Example:** If a new feature "Image Upload" is added to a social media platform, test previously existing features like "Post Status", "Add Friend", etc., to ensure they still work as expected.
  
- ***Pattern Testing:*** Based on predefined patterns, the software is tested. Tests the software based on predefined patterns, often derived from historical data or known issues.
  - **Concrete Example:** If historically a software crashes every 30 minutes, run the software and observe its behavior around the 30-minute mark.
  
- ***Orthogonal Array Testing:*** A systematic, statistical way of testing which involves pair-wise testing. A systematic and statistical way of testing that uses orthogonal arrays to ensure that all combinations of variables are tested with a minimum set of test cases.
  - **Concrete Example:** For a software with three parameters each having 3 possible values, instead of testing all 27 combinations, pick a subset that gives pair-wise coverage.

## White Box (Glass Box) Testing
**Definition:** White box testing, also known as glassbox testing, is a software testing method where the internal structure/design/implementation of the item being tested is known to the tester. It focuses on checking the internal logic, pathways, and code structure of the software.

**Examples:**
- ***Statement Coverage:*** Ensuring each statement in the software is executed at least once. Measures the percentage of statements that have been executed by the test suite.
  - **Concrete Example:** For a function that has five lines of code, write tests that ensure each of these five lines gets executed.
  
- ***Branch Coverage:*** Ensuring each branch (decision) in the software is executed at least once. Measures the percentage of branches (like `if` and `case` statements) that have been executed by the test suite.  Focuses on validating every possible branch (decision points like if, else, switch) in the code to ensure that each branch is executed at least once. It emphasizes the decision-making constructs within the software.  Think of "branch testing" as checking each individual decision point in the maze. At every junction or fork, you ensure that you can go both left and right (or any direction available). You're not concerned about exploring every possible route from the start to the finish; you just want to make sure that each decision point is checked.  In software, this means ensuring that every decision-making point (like an if or else statement) is tested at least once.
  - **Concrete Example:** For an `if-else` condition in the code, write tests that execute both the `if` part and the `else` part.
  
- ***Path Coverage:*** Ensuring all paths in the software are executed at least once. Measures the percentage of paths through the code that have been executed. It's more comprehensive than both statement and branch coverage.  Concentrates on validating every feasible path through the code. This means every sequence of instructions executed from the start of a function/method to its exit. It's a more exhaustive approach than branch testing as it considers combinations of branches.  Now, for "path testing", imagine trying to walk every possible route from the entrance to the exit of the maze. This means combining the decision points in every possible sequence to ensure you've covered all paths.
In software, this means testing every possible sequence of decisions to ensure all routes through a function or method are tested. It's more exhaustive because it looks at combinations of decisions, not just individual ones.
  - **Concrete Example:** For a function with multiple `if-else` conditions, write tests that cover all possible paths through these conditions.
  
- ***Loop Testing:*** Testing the loops in the software to ensure they work as expected. Focuses specifically on the validity of loop constructs, ensuring that loops run for their intended number of times and handle boundary conditions correctly.
  - **Concrete Example:** For a loop that runs 10 times, write tests that ensure it runs for all 10 iterations and handles boundary conditions correctly.
