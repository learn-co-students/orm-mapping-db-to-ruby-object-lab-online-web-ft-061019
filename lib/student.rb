class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    self.new.tap do |new_student|
      new_student.id = row[0]
      new_student.name = row[1]
      new_student.grade = row[2].to_i
    end

  end

  def self.all
    sql = <<-SQL
      SELECT *
      FROM students
    SQL
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end

  def self.all_students_in_grade_9
    self.all.select {|student| student.grade == 9}
  end

  def self.students_below_12th_grade
    self.all.select {|student| student.grade < 12 }
  end

  def self.first_X_students_in_grade_10(arg = 1)
    self.students_below_12th_grade.select {|student| student.grade == 10}[0..arg - 1]
  end

  def self.first_student_in_grade_10
    self.first_X_students_in_grade_10.first
  end

  def self.all_students_in_grade_X(grade)
   self.all.select {|student| student.grade == grade}
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE students.name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
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
