-- Student Performance & Course Recommendation System
-- Database Schema Setup

CREATE DATABASE student_recommendation_system;
USE student_recommendation_system;

-- 1. Departments Table
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,
    department_code VARCHAR(10) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Students Table
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(100) NOT NULL,
    student_email VARCHAR(100) UNIQUE NOT NULL,
    department_id INT,
    enrollment_year INT,
    current_gpa DECIMAL(3,2) DEFAULT 0.00,
    total_credits INT DEFAULT 0,
    status ENUM('Active', 'Graduated', 'Dropped') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- 3. Courses Table
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    course_name VARCHAR(200) NOT NULL,
    department_id INT,
    credits INT NOT NULL,
    difficulty_level ENUM('Beginner', 'Intermediate', 'Advanced') DEFAULT 'Beginner',
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- 4. Course Prerequisites Table (for recursive CTEs)
CREATE TABLE course_prerequisites (
    prerequisite_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT,
    prerequisite_course_id INT,
    is_mandatory BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (prerequisite_course_id) REFERENCES courses(course_id)
);

-- 5. Enrollments Table
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    semester VARCHAR(20),
    year INT,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Enrolled', 'Completed', 'Dropped', 'Failed') DEFAULT 'Enrolled',
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    UNIQUE KEY unique_enrollment (student_id, course_id, semester, year)
);

-- 6. Exams Table
CREATE TABLE exams (
    exam_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT,
    exam_name VARCHAR(100) NOT NULL,
    exam_type ENUM('Midterm', 'Final', 'Quiz', 'Assignment') DEFAULT 'Final',
    max_marks INT NOT NULL,
    weightage DECIMAL(5,2) DEFAULT 100.00, -- percentage weightage in final grade
    exam_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- 7. Student Exam Results Table
CREATE TABLE student_exam_results (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    exam_id INT,
    marks_obtained DECIMAL(5,2),
    grade CHAR(2), -- A+, A, B+, B, C+, C, D, F
    grade_points DECIMAL(3,2), -- 4.0 scale
    submission_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (exam_id) REFERENCES exams(exam_id),
    UNIQUE KEY unique_student_exam (student_id, exam_id)
);

-- 8. Course Grades Table (Final course grades)
CREATE TABLE course_grades (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    final_grade CHAR(2),
    grade_points DECIMAL(3,2),
    semester VARCHAR(20),
    year INT,
    completion_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    UNIQUE KEY unique_student_course_semester (student_id, course_id, semester, year)
);

-- 9. Student Recommendations Table
CREATE TABLE student_recommendations (
    recommendation_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    recommended_course_id INT,
    recommendation_score DECIMAL(5,2), -- 0-100 score
    reason TEXT,
    semester VARCHAR(20),
    year INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (recommended_course_id) REFERENCES courses(course_id)
);

-- Add indexes for better performance
CREATE INDEX idx_student_department ON students(department_id);
CREATE INDEX idx_course_department ON courses(department_id);
CREATE INDEX idx_enrollment_student ON enrollments(student_id);
CREATE INDEX idx_enrollment_course ON enrollments(course_id);
CREATE INDEX idx_exam_course ON exams(course_id);
CREATE INDEX idx_result_student ON student_exam_results(student_id);
CREATE INDEX idx_result_exam ON student_exam_results(exam_id);
CREATE INDEX idx_grade_student ON course_grades(student_id);
CREATE INDEX idx_grade_course ON course_grades(course_id);