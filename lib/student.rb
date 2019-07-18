class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    new_student = Student.new
    new_student.id = row[0]
    new_student.name = row[1]
    new_student.grade = row[2]
    new_student
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql_all = <<-SQL
      SELECT * FROM students;
    SQL

    all_students = DB[:conn].execute(sql_all).map {|student_row| self.new_from_db(student_row)}
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql_by_name = <<-SQL
      SELECT * FROM students
      WHERE students.name = ?;
    SQL
    
    student_found = DB[:conn].execute(sql_by_name, name)[0]
    self.new_from_db(student_found)
  end
  
  def self.all_students_in_grade_9
    sql_9th = <<-SQL
      SELECT * FROM students
      WHERE students.grade = 9;
    SQL

    DB[:conn].execute(sql_9th)
  end

  def self.students_below_12th_grade
    sql_12th_below = <<-SQL
      SELECT * FROM students
      WHERE students.grade < 12;
    SQL

    DB[:conn].execute(sql_12th_below).map do |student_raw|
      self.new_from_db(student_raw)
    end
  end

  
  def self.first_X_students_in_grade_10(limit_of_students)
    sql_students = <<-SQL
      SELECT * FROM students
      WHERE students.grade = 10
      LIMIT ?;
    SQL

    DB[:conn].execute(sql_students, limit_of_students).map do |student_raw|
      self.new_from_db(student_raw)
    end
  end

  def self.first_student_in_grade_10
    first_student = self.first_X_students_in_grade_10(1).first
  end

  def self.all_students_in_grade_X(grade)
    sql_all_x = <<-SQL
      SELECT * FROM students
      WHERE students.grade = ?;
    SQL

    students = DB[:conn].execute(sql_all_x, grade).map do |student_raw|
      self.new_from_db(student_raw)
    end
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
