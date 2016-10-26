require 'minitest/autorun'
require 'minitest/pride'
require './department'
require './migration'

class EmployeeReviews < Minitest::Test

  def setup
    ActiveRecord::Migration.verbose = false
    begin
      InitialMigration.migrate(:down)
    rescue
    end

    InitialMigration.migrate(:up)
  end

  def test_classes_exist
    assert Department
    assert Employee
  end

  def test_can_create_new_department
    a = Department.create!(name: "Marketing")
    refute_equal nil, a.id
  end

  def test_can_create_new_employee
    new_employee = Employee.create!(name: "Dan", email: "d@mail.com", phone: "914-555-5555", salary: 50000.00)
    refute_equal nil, new_employee.id
  end

  def test_can_add_employee_to_a_department
    a = Department.create!(name: "Marketing")
    new_employee = Employee.create!(name: "Dan", email: "d@mail.com", phone: "914-555-5555", salary: 50000.00)
    a.add_employee(new_employee)
    refute_equal nil, new_employee.department_id
  end

  def test_can_get_employee_name
    new_employee = Employee.create!(name: "Dan", email: "d@mail.com", phone: "914-555-5555", salary: 50000.00)
    assert_equal "Dan", new_employee.name
  end

  def test_can_get_employee_salary
    new_employee = Employee.create!(name: "Dan", email: "d@mail.com", phone: "914-555-5555", salary: 50000.00)
    assert_equal 50000.00, new_employee.salary
  end

  def test_can_get_a_department_name
    a = Department.create!(name: "Marketing")
    assert_equal "Marketing", a.name
  end

  def test_total_department_salary
    a = Department.create!(name: "Marketing")
    new_employee = Employee.create!(name: "Dan", email: "d@mail.com", phone: "914-555-5555", salary: 50000.00)
    old_employee = Employee.create!(name: "Yvonne", email: "Yvonne@urFired.com", phone: "919-123-4567", salary: 40000.00)
    assert a.add_employee(new_employee)
    assert a.add_employee(old_employee)
    assert_equal 90000.00, a.department_salary
  end

  def test_add_employee_review
    xavier = Employee.create!(name: "Xavier", email: "ProfX@marvel.com", phone: "911", salary: 70000.00)
    xavier.review = positive_review_one
    xavier.save
    assert_equal positive_review_one, xavier.review
  end

  def test_set_employee_performance
    new_employee = Employee.create!(name: "Dan", email: "d@mail.com", phone: "914-555-5555", salary: 50000.00)
    old_employee = Employee.create!(name: "Yvonne", email: "Yvonne@urFired.com", phone: "919-123-4567", salary: 4000.00)
    new_employee.satisfactory = true
    new_employee.save
    old_employee.satisfactory = false
    old_employee.save
    assert new_employee.satisfactory
    refute old_employee.satisfactory
  end

  def test_give_raise_by_percent
    new_employee = Employee.create!(name: "Dan", email: "d@mail.com", phone: "914-555-5555", salary: 50000.00)
    assert_equal 54000, new_employee.raise_by_percent(0.08)
  end

  def test_give_raise_by_amount
    new_employee = Employee.create!(name: "Dan", email: "d@mail.com", phone: "914-555-5555", salary: 50000.00)
    assert_equal 60000, new_employee.raise_by_amount(10000)
  end

  def test_department_raises_based_on_criteria
    a = Department.create!(name: "Marketing")
    xavier = Employee.create!(name: "Xavier", email: "ProfX@marvel.com", phone: "911", salary: 70000.00)
    new_employee = Employee.create!(name: "Dan", email: "d@mail.com", phone: "914-555-5555", salary: 50000.00)
    old_employee = Employee.create!(name: "Yvonne", email: "Yvonne@urFired.com", phone: "919-123-4567", salary: 40000.00)
    a.add_employee(xavier)
    a.add_employee(new_employee)
    a.add_employee(old_employee)
    xavier.satisfactory = true
    xavier.save
    new_employee.satisfactory = true
    new_employee.save
    old_employee.satisfactory = false
    old_employee.save
    a.department_raise(14000.00) {|e| e.satisfactory == true && e.salary < 60000.00}
    xavier.reload.salary
    new_employee.reload.salary
    old_employee.reload.salary
    assert_equal 70000.00, xavier.salary
    assert_equal 64000.00, new_employee.salary
    assert_equal 40000.00, old_employee.salary
  end

  def test_evaluate_employee_review
    xavier = Employee.create!(name: 'Xavier', email: 'ProfX@marvel.com', phone: '911', salary: 70000.00)
    xavier.add_employee_review(positive_review_one)
    assert xavier.satisfactory
  end

  def test_get_all_employees
    a = Department.create!(name: "Marketing")
    b = Department.create!(name: "Cool Kids")
    xavier = Employee.create!(name: "Xavier", email: "ProfX@marvel.com", phone: "911", salary: 70000.00)
    new_employee = Employee.create!(name: "Dan", email: "d@mail.com", phone: "914-555-5555", salary: 50000.00)
    old_employee = Employee.create!(name: "Yvonne", email: "Yvonne@urFired.com", phone: "919-123-4567", salary: 40000.00)
    another_guy = Employee.create!(name: "Dude", email: "dude@mcdudeface.com", phone: "919-555-4567", salary: 405000.00)
    a.add_employee(xavier)
    a.add_employee(new_employee)
    a.add_employee(old_employee)
    assert_equal 3, a.all_employees.size
  end

  def test_get_least_paid_employee
    a = Department.create!(name: "Marketing")
    b = Department.create!(name: "Cool Kids")
    xavier = Employee.create!(name: "Xavier", email: "ProfX@marvel.com", phone: "911", salary: 70000.00)
    new_employee = Employee.create!(name: "Dan", email: "d@mail.com", phone: "914-555-5555", salary: 50000.00)
    old_employee = Employee.create!(name: "Yvonne", email: "Yvonne@urFired.com", phone: "919-123-4567", salary: 40000.00)
    another_guy = Employee.create!(name: "Dude", email: "dude@mcdudeface.com", phone: "919-555-4567", salary: 405000.00)
    a.add_employee(xavier)
    a.add_employee(new_employee)
    a.add_employee(old_employee)
    assert_equal old_employee, a.least_paid_employee
  end

  def test_get_least_paid_employee
    a = Department.create!(name: "Marketing")
    b = Department.create!(name: "Cool Kids")
    xavier = Employee.create!(name: "Xavier", email: "ProfX@marvel.com", phone: "911", salary: 70000.00)
    new_employee = Employee.create!(name: "Dan", email: "d@mail.com", phone: "914-555-5555", salary: 50000.00)
    old_employee = Employee.create!(name: "Yvonne", email: "Yvonne@urFired.com", phone: "919-123-4567", salary: 40000.00)
    another_guy = Employee.create!(name: "Dude", email: "dude@mcdudeface.com", phone: "919-555-4567", salary: 405000.00)
    a.add_employee(xavier)
    a.add_employee(new_employee)
    a.add_employee(old_employee)
    assert_equal new_employee, a.employees_sorted_alphabetically[0]
    assert_equal old_employee, a.employees_sorted_alphabetically.last
  end

  def test_average_salary
    a = Department.create!(name: "Marketing")
    allie = Employee.create!(name: "Allie", salary: 100000)
    ziggy = Employee.create!(name: "Ziggfried", salary: 160000)
    a.add_employee(allie)
    a.add_employee(ziggy)
    assert_equal 130000, a.average_employee_salary
  end

  def test_employes_paid_above_average
    a = Department.create!(name: "Marketing")
    allie = Employee.create!(name: "Allie", salary: 100000)
    ziggy = Employee.create!(name: "Ziggfried", salary: 160000)
    buster = Employee.create!(name: "Buster", salary: 140000)
    a.add_employee(allie)
    a.add_employee(ziggy)
    a.add_employee(buster)
    assert_equal 2, a.employees_paid_above_average.size
  end

  def test_employee_name_palindrome
    tacocat = Employee.create!(name: "Taco cat")
    burritocat = Employee.create!(name: "Burrito Cat")
    assert tacocat.name_is_palindrome?
    refute burritocat.name_is_palindrome?
  end

  def test_largest_department
    ziggy = Employee.create!(name: "Ziggy")
    bean = Employee.create!(name: "Bean")
    twix = Employee.create!(name: "Twix")
    dogs = Department.create!(name: "Dogs")
    cats = Department.create!(name: "Cats")
    dogs.add_employee(ziggy)
    dogs.add_employee(bean)
    cats.add_employee(twix)
    assert_equal dogs, Department.biggest_department
  end

  def test_move_employees_to_another_department
    ziggy = Employee.create!(name: "Ziggy")
    bean = Employee.create!(name: "Bean")
    twix = Employee.create!(name: "Twix")
    dogs = Department.create!(name: "Dogs")
    cats = Department.create!(name: "Cats")
    dogs.add_employee(ziggy)
    dogs.add_employee(bean)
    cats.add_employee(twix)
    dogs.move_to!(cats)
    assert_equal 3, cats.all_employees.size
  end

  def test_raise_all_employees_by_percent
    ziggy = Employee.create!(name: "Ziggy", salary: 10000, satisfactory: true)
    bean = Employee.create!(name: "Bean", salary: 15000, satisfactory: false)
    twix = Employee.create!(name: "Twix", salary: 20000, satisfactory: true)
    dogs = Department.create!(name: "Dogs")
    cats = Department.create!(name: "Cats")
    dogs.add_employee(ziggy)
    dogs.add_employee(bean)
    cats.add_employee(twix)
    Department.salary_raise(0.1) { |emp| emp.satisfactory == true }
    assert_equal 11000, ziggy.reload.salary
    assert_equal 15000, bean.reload.salary
    assert_equal 22000, twix.reload.salary
  end

  private def negative_review_one
    "Zeke is a very positive person and encourages those around him, but he has not done well technically this year. There are two areas in which Zeke has room for improvement. First, when communicating verbally (and sometimes in writing), he has a tendency to use more words than are required. This conversational style does put people at ease, which is valuable, but it often makes the meaning difficult to isolate, and can cause confusion. Second, when discussing new requirements with project managers, less of the information is retained by Zeke long-term than is expected. This has a few negative consequences: 1) time is spent developing features that are not useful and need to be re-run, 2) bugs are introduced in the code and not caught because the tests lack the same information, and 3) clients are told that certain features are complete when they are inadequate. This communication limitation could be the fault of project management, but given that other developers appear to retain more information, this is worth discussing further."
  end

  private def negative_review_two
    "Thus far, there have been two concerns over Yvonne's performance, and both have been discussed with her in internal meetings. First, in some cases, Yvonne takes longer to complete tasks than would normally be expected. This most commonly manifests during development on existing applications, but can sometimes occur during development on new projects, often during tasks shared with Andrew. In order to accommodate for these preferences, Yvonne has been putting more time into fewer projects, which has gone well. Second, while in conversation, Yvonne has a tendency to interrupt, talk over others, and increase her volume when in disagreement. In client meetings, she also can dwell on potential issues even if the client or other attendees have clearly ruled the issue out, and can sometimes get off topic."
  end

  private def positive_review_one
    "Xavier is a huge asset to SciMed and is a pleasure to work with. He quickly knocks out tasks assigned to him, implements code that rarely needs to be revisited, and is always willing to help others despite his heavy workload. When Xavier leaves on vacation, everyone wishes he didn't have to go. Last year, the only concerns with Xavier performance were around ownership. In the past twelve months, he has successfully taken full ownership of both Acme and Bricks, Inc.  Aside from some false starts with estimates on Acme, clients are happy with his work and responsiveness, which is everything that his managers could ask for."
  end

  private def positive_review_two
    "Wanda has been an incredibly consistent and effective developer.  Clients are always satisfied with her work, developers are impressed with her productivity, and she's more than willing to help others even when she has a substantial workload of her own.  She is a great asset to Awesome Company, and everyone enjoys working with her.  During the past year, she has largely been devoted to work with the Cement Company, and she is the perfect woman for the job.  We know that work on a single project can become monotonous, however, so over the next few months, we hope to spread some of the Cement Company work to others.  This will also allow Wanda to pair more with others and spread her effectiveness to other projects."
  end
end
