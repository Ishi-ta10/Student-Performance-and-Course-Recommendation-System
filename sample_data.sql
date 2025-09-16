-- Sample Data Insertion for Student Recommendation System

-- Insert Departments
INSERT INTO departments (department_name, department_code) VALUES
('Computer Science', 'CS'),
('Mathematics', 'MATH'),
('Physics', 'PHYS'),
('Business Administration', 'BUS'),
('Engineering', 'ENG');

-- Insert Students
INSERT INTO students (student_name, student_email, department_id, enrollment_year, current_gpa, total_credits, status) VALUES
('Alice Johnson', 'alice.johnson@university.edu', 1, 2021, 3.75, 45, 'Active'),
('Bob Smith', 'bob.smith@university.edu', 1, 2020, 3.25, 60, 'Active'),
('Carol Davis', 'carol.davis@university.edu', 2, 2021, 3.90, 48, 'Active'),
('David Wilson', 'david.wilson@university.edu', 1, 2019, 3.50, 90, 'Active'),
('Emma Brown', 'emma.brown@university.edu', 3, 2022, 3.60, 30, 'Active'),
('Frank Miller', 'frank.miller@university.edu', 1, 2020, 2.80, 55, 'Active'),
('Grace Lee', 'grace.lee@university.edu', 4, 2021, 3.85, 42, 'Active'),
('Henry Taylor', 'henry.taylor@university.edu', 2, 2020, 3.40, 58, 'Active'),
('Ivy Chen', 'ivy.chen@university.edu', 1, 2021, 3.95, 47, 'Active'),
('Jack Anderson', 'jack.anderson@university.edu', 5, 2019, 3.30, 85, 'Active'),
('Kate Thompson', 'kate.thompson@university.edu', 1, 2022, 3.70, 28, 'Active'),
('Liam Garcia', 'liam.garcia@university.edu', 2, 2021, 3.55, 44, 'Active'),
('Mia Rodriguez', 'mia.rodriguez@university.edu', 3, 2020, 3.20, 62, 'Active'),
('Noah Martinez', 'noah.martinez@university.edu', 1, 2019, 3.80, 88, 'Active'),
('Olivia Clark', 'olivia.clark@university.edu', 4, 2022, 3.65, 32, 'Active');

-- Insert Courses
INSERT INTO courses (course_code, course_name, department_id, credits, difficulty_level, description) VALUES
-- Computer Science Courses
('CS101', 'Introduction to Programming', 1, 4, 'Beginner', 'Basic programming concepts using Python'),
('CS102', 'Data Structures', 1, 4, 'Intermediate', 'Arrays, linked lists, trees, and graphs'),
('CS201', 'Algorithms', 1, 4, 'Intermediate', 'Algorithm design and analysis'),
('CS301', 'Database Systems', 1, 3, 'Advanced', 'Database design and SQL'),
('CS302', 'Machine Learning', 1, 4, 'Advanced', 'Introduction to ML algorithms'),
('CS303', 'Software Engineering', 1, 3, 'Advanced', 'Software development lifecycle'),
('CS401', 'Advanced AI', 1, 4, 'Advanced', 'Deep learning and neural networks'),

-- Mathematics Courses
('MATH101', 'Calculus I', 2, 4, 'Beginner', 'Differential calculus'),
('MATH102', 'Calculus II', 2, 4, 'Intermediate', 'Integral calculus'),
('MATH201', 'Linear Algebra', 2, 3, 'Intermediate', 'Matrices and vector spaces'),
('MATH202', 'Statistics', 2, 3, 'Intermediate', 'Probability and statistical analysis'),
('MATH301', 'Advanced Statistics', 2, 4, 'Advanced', 'Advanced statistical methods'),

-- Physics Courses
('PHYS101', 'Physics I', 3, 4, 'Beginner', 'Mechanics and thermodynamics'),
('PHYS102', 'Physics II', 3, 4, 'Intermediate', 'Electricity and magnetism'),
('PHYS201', 'Quantum Physics', 3, 4, 'Advanced', 'Introduction to quantum mechanics'),

-- Business Courses
('BUS101', 'Introduction to Business', 4, 3, 'Beginner', 'Business fundamentals'),
('BUS201', 'Marketing', 4, 3, 'Intermediate', 'Marketing principles and strategies'),
('BUS301', 'Finance', 4, 4, 'Advanced', 'Corporate finance and investments'),

-- Engineering Courses
('ENG101', 'Engineering Fundamentals', 5, 4, 'Beginner', 'Basic engineering principles'),
('ENG201', 'Circuit Analysis', 5, 4, 'Intermediate', 'Electrical circuit analysis'),
('ENG301', 'Control Systems', 5, 4, 'Advanced', 'Feedback control systems');

-- Insert Course Prerequisites
INSERT INTO course_prerequisites (course_id, prerequisite_course_id, is_mandatory) VALUES
-- CS Prerequisites
(3, 2, TRUE), -- CS201 (Algorithms) requires CS102 (Data Structures)
(2, 1, TRUE), -- CS102 (Data Structures) requires CS101 (Intro Programming)
(4, 2, TRUE), -- CS301 (Database) requires CS102 (Data Structures)
(5, 3, TRUE), -- CS302 (ML) requires CS201 (Algorithms)
(5, 12, TRUE), -- CS302 (ML) requires MATH202 (Statistics)
(6, 2, TRUE), -- CS303 (Software Eng) requires CS102 (Data Structures)
(7, 5, TRUE), -- CS401 (Advanced AI) requires CS302 (ML)

-- Math Prerequisites
(9, 8, TRUE), -- MATH102 requires MATH101
(10, 9, TRUE), -- Linear Algebra requires Calculus II
(12, 11, TRUE), -- Advanced Stats requires Statistics

-- Physics Prerequisites
(14, 13, TRUE), -- Physics II requires Physics I
(15, 14, TRUE), -- Quantum Physics requires Physics II

-- Business Prerequisites
(17, 16, TRUE), -- Marketing requires Intro to Business
(18, 17, TRUE), -- Finance requires Marketing

-- Engineering Prerequisites
(20, 19, TRUE), -- Circuit Analysis requires Engineering Fundamentals
(21, 20, TRUE); -- Control Systems requires Circuit Analysis

-- Insert Exams
INSERT INTO exams (course_id, exam_name, exam_type, max_marks, weightage, exam_date) VALUES
-- CS101 Exams
(1, 'Midterm Exam', 'Midterm', 100, 30.00, '2023-10-15'),
(1, 'Final Exam', 'Final', 100, 50.00, '2023-12-10'),
(1, 'Programming Assignment 1', 'Assignment', 50, 20.00, '2023-09-30'),

-- CS102 Exams
(2, 'Midterm Exam', 'Midterm', 100, 35.00, '2023-10-20'),
(2, 'Final Exam', 'Final', 100, 45.00, '2023-12-15'),
(2, 'Data Structure Project', 'Assignment', 75, 20.00, '2023-11-15'),

-- Math101 Exams
(8, 'Midterm Exam', 'Midterm', 100, 40.00, '2023-10-12'),
(8, 'Final Exam', 'Final', 100, 60.00, '2023-12-08'),

-- Add more exams for other courses
(3, 'Algorithm Analysis Exam', 'Final', 100, 70.00, '2023-12-12'),
(4, 'Database Project', 'Assignment', 100, 40.00, '2023-11-20'),
(4, 'SQL Exam', 'Final', 100, 60.00, '2023-12-18');

-- Insert Student Exam Results
INSERT INTO student_exam_results (student_id, exam_id, marks_obtained, grade, grade_points) VALUES
-- Alice Johnson's results
(1, 1, 85.0, 'A-', 3.67), (1, 2, 90.0, 'A', 4.00), (1, 3, 45.0, 'A', 4.00),
(1, 4, 88.0, 'A-', 3.67), (1, 5, 92.0, 'A', 4.00), (1, 6, 68.0, 'B+', 3.33),

-- Bob Smith's results
(2, 1, 75.0, 'B', 3.00), (2, 2, 78.0, 'B+', 3.33), (2, 3, 38.0, 'B+', 3.33),
(2, 7, 82.0, 'A-', 3.67), (2, 8, 85.0, 'A-', 3.67),

-- Carol Davis's results (Math student)
(3, 7, 95.0, 'A', 4.00), (3, 8, 98.0, 'A', 4.00),

-- Add more results for other students
(4, 1, 80.0, 'B+', 3.33), (4, 2, 85.0, 'A-', 3.67), (4, 3, 42.0, 'A-', 3.67),
(5, 7, 88.0, 'A-', 3.67), (5, 8, 90.0, 'A', 4.00),
(6, 1, 65.0, 'C+', 2.33), (6, 2, 70.0, 'B-', 2.67), (6, 3, 32.0, 'C+', 2.33),
(7, 7, 92.0, 'A', 4.00), (7, 8, 89.0, 'A-', 3.67),
(8, 7, 78.0, 'B+', 3.33), (8, 8, 82.0, 'A-', 3.67),
(9, 1, 98.0, 'A', 4.00), (9, 2, 96.0, 'A', 4.00), (9, 3, 48.0, 'A', 4.00),
(10, 1, 77.0, 'B+', 3.33), (10, 2, 80.0, 'B+', 3.33);

-- Insert Course Grades (Final grades for completed courses)
INSERT INTO course_grades (student_id, course_id, final_grade, grade_points, semester, year) VALUES
-- Completed courses
(1, 1, 'A-', 3.67, 'Fall', 2023), -- Alice completed CS101
(1, 8, 'A', 4.00, 'Fall', 2023), -- Alice completed MATH101
(2, 1, 'B+', 3.33, 'Fall', 2023), -- Bob completed CS101
(2, 8, 'A-', 3.67, 'Fall', 2023), -- Bob completed MATH101
(3, 8, 'A', 4.00, 'Fall', 2023), -- Carol completed MATH101
(4, 1, 'A-', 3.67, 'Spring', 2023), -- David completed CS101
(5, 8, 'A-', 3.67, 'Fall', 2023), -- Emma completed MATH101
(6, 1, 'C+', 2.33, 'Fall', 2023), -- Frank completed CS101
(7, 1, 'A', 4.00, 'Spring', 2023), -- Grace completed CS101
(8, 8, 'B+', 3.33, 'Fall', 2023), -- Henry completed MATH101
(9, 1, 'A', 4.00, 'Fall', 2023), -- Ivy completed CS101
(10, 1, 'B+', 3.33, 'Spring', 2023), -- Jack completed CS101

-- Some intermediate level courses
(1, 2, 'A-', 3.67, 'Spring', 2024), -- Alice completed Data Structures
(4, 2, 'B+', 3.33, 'Fall', 2023), -- David completed Data Structures
(9, 2, 'A', 4.00, 'Spring', 2024), -- Ivy completed Data Structures
(14, 1, 'A-', 3.67, 'Fall', 2022), -- Noah completed CS101
(14, 2, 'A', 4.00, 'Spring', 2023), -- Noah completed Data Structures
(14, 3, 'B+', 3.33, 'Fall', 2023); -- Noah completed Algorithms

-- Insert Current Enrollments
INSERT INTO enrollments (student_id, course_id, semester, year, status) VALUES
-- Current semester enrollments
(1, 3, 'Spring', 2024, 'Enrolled'), -- Alice enrolled in Algorithms
(1, 10, 'Spring', 2024, 'Enrolled'), -- Alice enrolled in Linear Algebra
(2, 2, 'Spring', 2024, 'Enrolled'), -- Bob enrolled in Data Structures
(3, 9, 'Spring', 2024, 'Enrolled'), -- Carol enrolled in Calculus II
(4, 4, 'Spring', 2024, 'Enrolled'), -- David enrolled in Database Systems
(5, 13, 'Spring', 2024, 'Enrolled'), -- Emma enrolled in Physics I
(6, 8, 'Spring', 2024, 'Enrolled'), -- Frank enrolled in Math101 (retake)
(7, 17, 'Spring', 2024, 'Enrolled'), -- Grace enrolled in Marketing
(8, 10, 'Spring', 2024, 'Enrolled'), -- Henry enrolled in Linear Algebra
(9, 3, 'Spring', 2024, 'Enrolled'), -- Ivy enrolled in Algorithms
(10, 20, 'Spring', 2024, 'Enrolled'), -- Jack enrolled in Circuit Analysis
(11, 1, 'Spring', 2024, 'Enrolled'), -- Kate enrolled in CS101
(12, 9, 'Spring', 2024, 'Enrolled'), -- Liam enrolled in Calculus II
(13, 14, 'Spring', 2024, 'Enrolled'), -- Mia enrolled in Physics II
(14, 4, 'Spring', 2024, 'Enrolled'), -- Noah enrolled in Database Systems
(15, 16, 'Spring', 2024, 'Enrolled'); -- Olivia enrolled in Intro to Business