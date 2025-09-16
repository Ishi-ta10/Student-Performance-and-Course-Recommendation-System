-- Advanced SQL Queries for Student Performance Analysis

-- 1. Window Functions: Rank students by GPA within each department
SELECT 
    s.student_id,
    s.student_name,
    d.department_name,
    s.current_gpa,
    s.total_credits,
    RANK() OVER (PARTITION BY d.department_id ORDER BY s.current_gpa DESC) as gpa_rank,
    DENSE_RANK() OVER (PARTITION BY d.department_id ORDER BY s.current_gpa DESC) as gpa_dense_rank,
    ROW_NUMBER() OVER (PARTITION BY d.department_id ORDER BY s.current_gpa DESC, s.total_credits DESC) as row_num,
    ROUND(AVG(s.current_gpa) OVER (PARTITION BY d.department_id), 2) as dept_avg_gpa,
    ROUND(s.current_gpa - AVG(s.current_gpa) OVER (PARTITION BY d.department_id), 2) as gpa_diff_from_dept_avg
FROM students s
JOIN departments d ON s.department_id = d.department_id
WHERE s.status = 'Active'
ORDER BY d.department_name, gpa_rank;

-- 2. Recursive CTE: Build complete course prerequisite chains
WITH RECURSIVE PrerequisiteChain AS (
    -- Base case: courses with their direct prerequisites
    SELECT 
        c.course_id,
        c.course_name,
        c.course_code,
        cp.prerequisite_course_id,
        pc.course_name as prerequisite_name,
        pc.course_code as prerequisite_code,
        1 as level_depth
    FROM courses c
    LEFT JOIN course_prerequisites cp ON c.course_id = cp.course_id
    LEFT JOIN courses pc ON cp.prerequisite_course_id = pc.course_id
    
    UNION ALL
    
    -- Recursive case: prerequisites of prerequisites
    SELECT 
        prc.course_id,
        prc.course_name,
        prc.course_code,
        cp2.prerequisite_course_id,
        pc2.course_name as prerequisite_name,
        pc2.course_code as prerequisite_code,
        prc.level_depth + 1
    FROM PrerequisiteChain prc
    JOIN course_prerequisites cp2 ON prc.prerequisite_course_id = cp2.course_id
    JOIN courses pc2 ON cp2.prerequisite_course_id = pc2.course_id
    WHERE prc.level_depth < 5  -- Prevent infinite recursion
)
SELECT 
    course_code,
    course_name,
    COALESCE(prerequisite_code, 'No Prerequisites') as prerequisite_code,
    COALESCE(prerequisite_name, 'No Prerequisites') as prerequisite_name,
    level_depth
FROM PrerequisiteChain
ORDER BY course_code, level_depth;

-- 3. Student Performance Analytics with Multiple Window Functions
SELECT 
    s.student_id,
    s.student_name,
    d.department_name,
    s.current_gpa,
    s.total_credits,
    -- Ranking within department
    RANK() OVER (PARTITION BY s.department_id ORDER BY s.current_gpa DESC) as dept_rank,
    -- Percentile ranking
    PERCENT_RANK() OVER (PARTITION BY s.department_id ORDER BY s.current_gpa) as percentile_rank,
    -- Running total of credits
    SUM(s.total_credits) OVER (PARTITION BY s.department_id ORDER BY s.current_gpa DESC) as running_credits,
    -- Lead and Lag for comparison
    LAG(s.current_gpa, 1) OVER (PARTITION BY s.department_id ORDER BY s.current_gpa DESC) as next_higher_gpa,
    LEAD(s.current_gpa, 1) OVER (PARTITION BY s.department_id ORDER BY s.current_gpa DESC) as next_lower_gpa,
    -- First and Last values
    FIRST_VALUE(s.current_gpa) OVER (PARTITION BY s.department_id ORDER BY s.current_gpa DESC) as highest_dept_gpa,
    LAST_VALUE(s.current_gpa) OVER (PARTITION BY s.department_id ORDER BY s.current_gpa DESC 
                                    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as lowest_dept_gpa
FROM students s
JOIN departments d ON s.department_id = d.department_id
WHERE s.status = 'Active'
ORDER BY d.department_name, s.current_gpa DESC;

-- 4. Complex Joins: Student performance across courses with recommendations
SELECT 
    s.student_id,
    s.student_name,
    s.current_gpa,
    d.department_name,
    -- Completed courses info
    COUNT(DISTINCT cg.course_id) as courses_completed,
    ROUND(AVG(cg.grade_points), 2) as avg_course_grade,
    -- Current enrollments
    COUNT(DISTINCT e.course_id) as current_enrollments,
    -- Recommendations
    COUNT(DISTINCT sr.recommended_course_id) as recommendations_count,
    -- Best recommendation
    MAX(sr.recommendation_score) as best_recommendation_score,
    -- Performance trend (comparing recent vs older grades)
    (SELECT ROUND(AVG(grade_points), 2) 
     FROM course_grades cg2 
     WHERE cg2.student_id = s.student_id 
     AND cg2.year >= 2024) as recent_performance,
    (SELECT ROUND(AVG(grade_points), 2) 
     FROM course_grades cg3 
     WHERE cg3.student_id = s.student_id 
     AND cg3.year < 2024) as historical_performance
FROM students s
JOIN departments d ON s.department_id = d.department_id
LEFT JOIN course_grades cg ON s.student_id = cg.student_id
LEFT JOIN enrollments e ON s.student_id = e.student_id AND e.status = 'Enrolled'
LEFT JOIN student_recommendations sr ON s.student_id = sr.student_id AND sr.is_active = TRUE
WHERE s.status = 'Active'
GROUP BY s.student_id, s.student_name, s.current_gpa, d.department_name
ORDER BY s.current_gpa DESC;

-- 5. Department Performance Heatmap Data
SELECT 
    d.department_name,
    d.department_code,
    c.difficulty_level,
    COUNT(DISTINCT cg.student_id) as student_count,
    COUNT(DISTINCT cg.course_id) as course_count,
    ROUND(AVG(cg.grade_points), 2) as avg_grade_points,
    ROUND(MIN(cg.grade_points), 2) as min_grade_points,
    ROUND(MAX(cg.grade_points), 2) as max_grade_points,
    -- Grade distribution
    SUM(CASE WHEN cg.grade_points >= 3.7 THEN 1 ELSE 0 END) as a_grades,
    SUM(CASE WHEN cg.grade_points >= 3.3 AND cg.grade_points < 3.7 THEN 1 ELSE 0 END) as b_plus_grades,
    SUM(CASE WHEN cg.grade_points >= 3.0 AND cg.grade_points < 3.3 THEN 1 ELSE 0 END) as b_grades,
    SUM(CASE WHEN cg.grade_points >= 2.7 AND cg.grade_points < 3.0 THEN 1 ELSE 0 END) as b_minus_grades,
    SUM(CASE WHEN cg.grade_points < 2.7 THEN 1 ELSE 0 END) as below_b_minus,
    -- Performance indicators
    CASE 
        WHEN AVG(cg.grade_points) >= 3.5 THEN 'Excellent'
        WHEN AVG(cg.grade_points) >= 3.0 THEN 'Good'
        WHEN AVG(cg.grade_points) >= 2.5 THEN 'Average'
        ELSE 'Needs Improvement'
    END as performance_category
FROM departments d
JOIN courses c ON d.department_id = c.department_id
JOIN course_grades cg ON c.course_id = cg.course_id
GROUP BY d.department_id, d.department_name, d.department_code, c.difficulty_level
ORDER BY d.department_name, c.difficulty_level;

-- 6. Next Recommended Course for Each Student (Main Deliverable)
SELECT 
    s.student_id,
    s.student_name,
    s.current_gpa,
    d.department_name,
    -- Current status
    s.total_credits,
    CASE 
        WHEN s.total_credits < 30 THEN 'Freshman'
        WHEN s.total_credits < 60 THEN 'Sophomore'
        WHEN s.total_credits < 90 THEN 'Junior'
        ELSE 'Senior'
    END as academic_level,
    -- Top recommendation
    sr.recommended_course_id,
    rc.course_code as recommended_course_code,
    rc.course_name as recommended_course_name,
    rc.credits as recommended_course_credits,
    rc.difficulty_level as recommended_difficulty,
    sr.recommendation_score,
    sr.reason as recommendation_reason,
    -- Prerequisites check
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM course_prerequisites cp 
            WHERE cp.course_id = sr.recommended_course_id
            AND cp.prerequisite_course_id NOT IN (
                SELECT course_id FROM course_grades 
                WHERE student_id = s.student_id AND grade_points >= 2.0
            )
        ) THEN 'Prerequisites Not Met'
        ELSE 'Prerequisites Met'
    END as prerequisite_status,
    -- Additional context
    (SELECT COUNT(*) FROM course_grades WHERE student_id = s.student_id) as completed_courses,
    (SELECT COUNT(*) FROM enrollments WHERE student_id = s.student_id AND status = 'Enrolled') as current_courses
FROM students s
JOIN departments d ON s.department_id = d.department_id
JOIN student_recommendations sr ON s.student_id = sr.student_id AND sr.is_active = TRUE
JOIN courses rc ON sr.recommended_course_id = rc.course_id
WHERE s.status = 'Active'
AND sr.recommendation_score = (
    SELECT MAX(recommendation_score) 
    FROM student_recommendations sr2 
    WHERE sr2.student_id = s.student_id AND sr2.is_active = TRUE
)
ORDER BY s.current_gpa DESC, sr.recommendation_score DESC;

-- 7. Course Success Rate Analysis
SELECT 
    c.course_code,
    c.course_name,
    c.difficulty_level,
    d.department_name,
    COUNT(DISTINCT cg.student_id) as total_students,
    SUM(CASE WHEN cg.grade_points >= 2.0 THEN 1 ELSE 0 END) as passing_students,
    ROUND((SUM(CASE WHEN cg.grade_points >= 2.0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) as pass_rate,
    ROUND(AVG(cg.grade_points), 2) as avg_grade_points,
    -- Grade distribution percentages
    ROUND((SUM(CASE WHEN cg.grade_points >= 3.7 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 1) as a_percentage,
    ROUND((SUM(CASE WHEN cg.grade_points >= 3.0 AND cg.grade_points < 3.7 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 1) as b_percentage,
    ROUND((SUM(CASE WHEN cg.grade_points >= 2.0 AND cg.grade_points < 3.0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 1) as c_percentage,
    ROUND((SUM(CASE WHEN cg.grade_points < 2.0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 1) as fail_percentage
FROM courses c
JOIN departments d ON c.department_id = d.department_id
JOIN course_grades cg ON c.course_id = cg.course_id
GROUP BY c.course_id, c.course_code, c.course_name, c.difficulty_level, d.department_name
HAVING COUNT(DISTINCT cg.student_id) >= 2  -- Only show courses with at least 2 students
ORDER BY pass_rate DESC, avg_grade_points DESC;

-- 8. Student Progression Analysis
WITH StudentProgression AS (
    SELECT 
        s.student_id,
        s.student_name,
        s.enrollment_year,
        s.current_gpa,
        -- Calculate expected graduation year
        s.enrollment_year + 4 as expected_graduation_year,
        -- Calculate completion rate
        ROUND((s.total_credits / 120.0) * 100, 1) as completion_percentage,
        -- Estimate remaining semesters
        CEILING((120 - s.total_credits) / 15.0) as estimated_remaining_semesters,
        -- Performance trend
        ROW_NUMBER() OVER (ORDER BY s.current_gpa DESC) as overall_rank
    FROM students s
    WHERE s.status = 'Active'
)
SELECT 
    sp.*,
    CASE 
        WHEN sp.completion_percentage >= 75 THEN 'On Track - Senior'
        WHEN sp.completion_percentage >= 50 THEN 'On Track - Junior'
        WHEN sp.completion_percentage >= 25 THEN 'On Track - Sophomore'
        ELSE 'Freshman Level'
    END as progression_status,
    CASE 
        WHEN sp.current_gpa >= 3.5 THEN 'Excellent'
        WHEN sp.current_gpa >= 3.0 THEN 'Good'
        WHEN sp.current_gpa >= 2.5 THEN 'Satisfactory'
        ELSE 'Needs Improvement'
    END as academic_standing
FROM StudentProgression sp
ORDER BY sp.current_gpa DESC;