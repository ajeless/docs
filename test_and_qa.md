# Test Engineering and QA

## Verification vs. Validation in Software Testing

**Verification**:

Verification answers the question: "Are we building the product right?"

- **Purpose**: Verification focuses on ensuring that the software is built correctly and that it adheres to its specified requirements and design.
- **Activities**: It involves reviewing and inspecting work products, conducting static analysis, and performing various testing activities to confirm that the software aligns with its intended design and requirements.
- **Scope**: Verification is an internal process and typically occurs during the development phase, involving developers and testers.
- **Examples**:
  - **Code Reviews**: Developers review each other's code to identify coding standards violations, logical errors, and design flaws.
  - **Static Code Analysis**: Tools like linters and static analyzers examine the source code for potential issues without executing it.
  - **Unit Testing**: Developers write and run unit tests to ensure that individual components or units of code function correctly.

**Validation**:

Validation answers the question: "Are we building the right product"?

- **Purpose**: Validation focuses on ensuring that the software meets the needs and expectations of the end users and stakeholders. It answers the question, "Are we building the right product?"
- **Activities**: Validation involves dynamic testing, user acceptance testing (UAT), and other activities that assess the software's functionality, usability, and overall fitness for its intended purpose.
- **Scope**: Validation is an external process and typically occurs after the development phase when the software is ready to be delivered to users or customers.
- **Examples**:
  - **User Acceptance Testing (UAT)**: End users or representatives from the user community test the software to confirm that it meets their requirements and works as expected.
  - **Functional Testing**: Testers verify that the software functions according to the specified requirements, including various use cases and scenarios.
  - **Usability Testing**: Testers or users assess the software's user interface, ease of use, and overall user experience.

**Key Differences**:

1. **Focus**:
   - **Verification** focuses on confirming that the software is built correctly according to its specifications and design.
   - **Validation** focuses on confirming that the software meets the needs and expectations of its users and stakeholders.

2. **Activities**:
   - **Verification** involves activities like code reviews, static analysis, and unit testing.
   - **Validation** involves dynamic testing, UAT, and usability testing, among others.

3. **Timing**:
   - **Verification** typically occurs during the development phase, involving internal stakeholders.
   - **Validation** occurs after development when the software is ready for user testing, involving external stakeholders.

4. **Scope**:
   - **Verification** assesses the software's internal attributes and adherence to requirements.
   - **Validation** assesses the software's external attributes, usability, and fitness for its intended purpose.

In summary, verification ensures that the software is built correctly, while validation ensures that it is the right product that meets user needs and expectations. Both verification and validation are essential components of software quality assurance and are carried out to ensure the overall quality and reliability of the software.


<hr>

## Common definitions used in testing and quality assurance

**Dependability** - The quality of a delivered service such that reliance can justifiably be placed on the service.  

**Error** - The part of the system or service that can lead to failure.  

**Failure** - Unwanted effects that occur when the delivered service deviates from the specification of the expected service.  

**Fault/Defect/Bug** - The root cause of an error.  Faults may be caused by poor requirements specification, design flaws, manufacturing defects, wear and tear on hardware such as damage or short circuits, and coding mistakes in software.

**Latent Error** - An error that exists but does not necessarily cause a failure.  It usually remains dormant until it is triggered by running the portion of the code where it resides resulting in failure.  

**Effective Error** - An error that results in noticeable system failure or deviation from expected behavior.  Unlike latent errors, effective errors manifest as active (that is noticeable) failure.

**Service** - The system behavior as perceived by the user.  

**Reliability** - The likelihood an end user will encounter a fault that triggers an error leading to failure.  The more reliable the delivered service is, the less likely an end user is to encounter faults or experience failures.