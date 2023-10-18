# V-Model Overview

The V-Model is a Software Development Life Cycle (SDLC) model where processes occur sequentially, forming a V-shape. It's also termed the Verification and Validation model. Essentially, it's an evolved Waterfall model where each development phase has a corresponding testing phase.

<img alt="v model of software testing" src="./sdlc_v_model.jpg"/>

## Design of the V-Model

In the V-Model, testing phases correspond to and are planned alongside development phases. The left side of the 'V' represents Verification phases, while the right side represents Validation phases. The Coding Phase connects both sides.

## Verification Phases

1. **Business Requirement Analysis:** Understand product requirements from the customer's viewpoint. This phase often involves deep communication to grasp customer expectations and requirements, setting the stage for acceptance test design.
2. **System Design:** Post requirement clarity, the entire system is designed, detailing hardware and communication setups. System test plans are crafted at this juncture.
3. **Architectural Design (High-Level Design):** Architectural specifics are determined. Multiple technical approaches might be proposed, with the best one chosen based on feasibility. This phase also breaks down the system design into functional modules and defines inter-module communication.
4. **Module Design (Low-Level Design):** Detailed designs for system modules are created. Unit tests, crucial for early error detection, are designed in this phase.
5. **Coding Phase:** Actual coding of modules occurs, with the most appropriate programming language chosen based on system requirements. Code undergoes reviews and optimizations before finalization.

## Validation Phases

1. **Unit Testing:** Execute unit tests designed during the module design phase.
2. **Integration Testing:** Test the interaction of internal modules.
3. **System Testing:** Ensure the entire system functions correctly and interacts seamlessly with external systems.
4. **Acceptance Testing:** Test the product in the user environment, identifying compatibility and non-functional issues.

## V-Model Application

The V-Model's application mirrors the Waterfall model due to their sequential natures. It's best suited for projects where:

- Requirements are clear and stable.
- Technology is understood by the team.
- There's no ambiguity in requirements.
- The project duration is short.

## Pros and Cons of the V-Model

**Advantages:**
- Straightforward and easy to grasp.
- Ideal for smaller, well-defined projects.
- Each phase has clear deliverables and reviews.

**Disadvantages:**
- Not adaptable to changes.
- Unsuitable for complex, long-term, or object-oriented projects.
- Challenges arise if changes are needed during the testing stage.
- Working software is only available late in the cycle.
