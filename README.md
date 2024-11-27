# Job Shop Scheduling Problem 

## Description
This code solves a job shop scheduling problem using linear programming. The problem involves scheduling a set of jobs on a set of machines, each with different processing times. The objective is to minimize the makespan, which is the total time to complete all jobs. The code uses mathematical symbols and equations from **machine_scheduling.pdf**.

## Mathematical Formulation
The problem is formulated as a mixed-integer linear program (MILP). The following sets, parameters, variables, and equations define the problem:

### Sets
* **m, mi, mj**: Machines (e.g., A, B, C)
* **u**: Units (e.g., A1)
* **(m, u)**: Machine-unit mapping (e.g., A1 to A)
* **p, pi, pj**: Products
* **o, oi, oj**: Job Numbers
* **c**: Product Categories
* **(p, c)**: Product Category assignment
* **(mi, mj)**: Process order pairs (e.g., A, B)

### Parameters
* **t(p, m)**: Processing times for each product on each machine
* **penalty**: Penalty for consecutive same product types
* **max_t**: Big M scalar for upper bound, set as the maximum total time

### Variables
* **y(u, o, p)**: Binary variable, 1 if product p is scheduled on machine-unit u for job number o, 0 otherwise
* **z(u, c)**: Binary variable, 1 if the same product category is scheduled on the same machine-unit u for consecutive jobs, 0 otherwise
* **x_start(u, o, p)**: Start time of product p on machine-unit u for job number o
* **obj**: Objective function - max processing time + penalties
* **x_makespan**: Max processing time for the objective function

### Equations
* **set_next_start(u, o, p)**: Sets the start time on or after the end time of the previous job (o) per unit u
* **link_constraint(u, o, p)**: Links variables x_start and y together
* **set_sequence(u, o)**: Assigns unique product to u, o
* **assign_unique_product(u, o)**: Finds consecutive products for u, o, c
* **set_process_order(p, mi, mj)**: Processing order (e.g., machine A must be processed before B and B before C)
* **force_all_scheduled(p, m)**: Ensures all products are scheduled on the appropriate machines
* **set_makespan(p, m)**: Calculates the max processing time (makespan)
* **set_obj**: Calculates the objective function

## Python Implementation
The Python code implements the mathematical formulation using an optimization library such as PuLP, Pyomo, or OR-Tools. 

**Note:** This response regarding specific Python libraries is not found within the provided source documents.  It is from general knowledge of optimization tools and may need to be independently verified.

The code defines the variables, constraints, and objective function in the syntax of the chosen library and then uses the library's functions to solve the problem.

## Usage
To use the code, you need to:

1. **Install the required optimization library:**
   * For PuLP, use `pip install pulp`
   * For Pyomo, use `pip install pyomo`
   * For OR-Tools, use `pip install ortools`
2. **Input the problem data:**
   * Define the sets of machines, units, products, job numbers, and product categories.
   * Specify the processing times for each product on each machine.
   * Set the penalty for consecutive same product types.
3. **Run the code:**
   * Execute the Python script to solve the job shop scheduling problem.

## Output
The code will output:

* The optimal schedule, indicating the start time and machine assignment for each job.
* The minimum makespan.

## Example
The code includes an example problem instance with sample data. You can modify this example to solve your own job shop scheduling problems.
