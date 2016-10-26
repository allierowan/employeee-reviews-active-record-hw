# Employee Reviews

## Description

Allows the user to keep track of a department's staff, and the details of each employee within a department.

## Features

* Create new departments:
```
marketing = Department.new("Marketing")
```
* Create new employees:
```
new_employee = Employee.new(name, phone, email, salary )
```
* Add employees to a department:
```
marketing.add_employee(employee)
```
* Add text reviews to each employee using:
```
new_employee.review = "This employee did very well"
```
* Give raises to an entire department.
* Give raises to specific employees in a department based upon criteria of the user's choosing.
* Scan employee review text and evaluate an employee's performance.
* Access an employees performance rating rating at any time.
