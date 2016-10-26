require './db_connection'
require './employee'

class Department < ActiveRecord::Base
  has_many :employees

  def add_employee(new_employee)
    new_employee.department_id = self.id
    new_employee.save
  end

  def department_salary
    staff = all_employees.to_a
    staff.reduce(0.0) {|sum, e| sum + e.salary}
  end

  # def add_employee_review(review)
  #   @review = review
  # end

  def department_raise(alloted_amount)
    raise_eligible = all_employees.select {|e| yield(e)}.to_a
    amount = alloted_amount / raise_eligible.length
    raise_eligible.each { |e| e.raise_by_amount(amount) }
  end

  def all_employees
    Employee.where(department_id: self.id)
  end

  def least_paid_employee
    all_employees.order(salary: :asc).first
  end

  def employees_sorted_alphabetically
    all_employees.order(name: :asc)
  end

  def average_employee_salary
    department_salary / all_employees.size
  end

  def employees_paid_above_average
    all_employees.select { |e| e.salary > average_employee_salary }
  end

  def department_size
     Employee.where(department_id: self.id).size
   end

   def self.biggest_department
     a = Department.all.max_by { |dept| dept.department_size }
   end

  def move_to!(department)
    all_employees.each do |emp|
      emp.department_id = department.id
      emp.save
    end
  end

  def self.salary_raise(percent)
    global_employees = []
    Department.all.each do |dept|
      dept.all_employees.each do |emp|
        global_employees << emp
      end
    end
    raise_eligible = global_employees.select { |emp| yield(emp) }
    raise_eligible.each { |e| e.raise_by_percent(percent) }
  end
end
