# Dependability in Software Systems

Dependability is a crucial aspect of software systems. It refers to the reliability of a software system in delivering its intended service. This article delves into the terminology associated with dependability, ensuring clarity in discussions related to software testing.

## 1. Key Definitions:

- **Service:** The behavior of a system as perceived by its user. For instance, an airplane's service is transporting passengers from one location to another.
- **Failure:** A deviation of the delivered service from its intended specification. For example, if a shopping website returns an error when a user tries to make a purchase, it's a visible failure.
- **Error:** A part of the system state that may lead to a failure. Errors can be latent (hidden) or effective (active). A latent error becomes effective when a specific condition in the software triggers it.
- **Fault:** The underlying cause of an error. In mechanical systems, a fault could be a broken component. In software, it could stem from a programmer's misunderstanding of system requirements.

## 2. Dependability Approaches:

- **Fault Avoidance:** Preventing specific faults by design. Different programming languages offer varying levels of fault avoidance. For example, Java has built-in array bounds checking, preventing buffer overflow errors common in languages like C.
- **Fault Tolerance:** Designing systems with redundancy to ensure continued operation even when a component fails. This approach is common in critical systems, such as aircraft control systems or large-scale websites.
- **Error Removal:** The process of identifying and eliminating errors. Verification techniques are employed to remove latent errors.
- **Error Forecasting:** Estimating the likelihood of failures based on the software's behavior.

## 3. Dependability Metrics:

- **Availability:** The probability that software is ready to respond to user requests at any given time.
- **Reliability:** The continuous provision of correct service. A system can be available but not reliable, and vice versa. For instance, a car that never starts (unreliable) is safe when stationary but not available for use.
- **Safety:** Ensuring that software failures don't lead to catastrophic outcomes.
- **Integrity:** Preventing unauthorized system alterations, crucial for security.
- **Maintainability:** The ease with which software can be modified or repaired.

## 4. Measuring Dependability:

- **Mean Time Between Failures (MTBF):** The average time between system failures.
- **Recoverability:** The speed at which a system can be restored after a failure, measured as Mean Time To Repair (MTTR).
- **Availability Calculation:** MTBF / (MTBF + MTTR).

## 5. Planning for Failures in Critical Systems:

In critical systems, it's essential to anticipate failures. Software must be robust, capable of handling unexpected inputs or conditions. The rigor of testing regimens should be determined based on the software's criticality.

## Conclusion:

While testing is vital for building dependable software, it's only a part of a comprehensive strategy. A holistic approach, encompassing fault avoidance, fault tolerance, error removal, and error forecasting, is essential for creating truly dependable software systems.
