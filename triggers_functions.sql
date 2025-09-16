-- Triggers and Stored Procedures for GPA Updates and Recommendations

-- 1. Trigger to automatically update student GPA when grades are inserted
DELIMITER //

CREATE TRIGGER update_gpa_after_grade_insert 
AFTER INSERT ON course_grades
FOR EACH ROW
BEGIN
    DECLARE total_grade_points DECIMAL(10,2);
    DECLARE total_credits INT;
    DECLARE new_gpa DECIMAL(3,2);
    
    -- Calculate total grade points and credits for the student
    SELECT 
        SUM(cg.grade_points * c.credits),
        SUM(c.credits)
    INTO total_grade_points, total_credits
    FROM course_grades cg
    JOIN courses c ON cg.course_id = c.course_id
    WHERE cg.student_id = NEW.student_id;
    
    -- Calculate new GPA
    IF total_credits > 0 THEN
        SET new_gpa = total_grade_points / total_credits;
    ELSE
        SET new_gpa = 0.00;
    END IF;
    
    -- Update student record
    UPDATE students 
    SET current_gpa = new_gpa, total_credits = total_credits
    WHERE student_id = NEW.student_id;
END//

-- 2. Trigger to update GPA when grades are updated
CREATE TRIGGER update_gpa_after_grade_update 
AFTER UPDATE ON course_grades
FOR EACH ROW
BEGIN
    DECLARE total_grade_points DECIMAL(10,2);
    DECLARE total_credits INT;
    DECLARE new_gpa DECIMAL(3,2);
    
    SELECT 
        SUM(cg.grade_points * c.credits),
        SUM(c.credits)
    INTO total_grade_points, total_credits
    FROM course_grades cg
    JOIN courses c ON cg.course_id = c.course_id
    WHERE cg.student_id = NEW.student_id;
    
    IF total_credits > 0 THEN
        SET new_gpa = total_grade_points / total_credits;
    ELSE
        SET new_gpa = 0.00;
    END IF;
    
    UPDATE students 
    SET current_gpa = new_gpa, total_credits = total_credits
    WHERE student_id = NEW.student_id;
END//

-- 3. Stored Procedure to generate course recommendations
CREATE PROCEDURE GenerateCourseRecommendations(IN student_id_param INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE course_id_var INT;
    DECLARE recommendation_score_var DECIMAL(5,2);
    DECLARE reason_var TEXT;
    
    -- Clear existing recommendations for the student
    DELETE FROM student_recommendations 
    WHERE student_id = student_id_param AND is_active = TRUE;
    
    -- Cursor to find eligible courses
    DECLARE course_cursor CURSOR FOR
        SELECT 
            c.course_id,
            CASE 
                WHEN s.current_gpa >= 3.5 AND c.difficulty_level = 'Advanced' THEN 90.0
                WHEN s.current_gpa >= 3.0 AND c.difficulty_level = 'Intermediate' THEN 85.0
                WHEN s.current_gpa >= 2.5 AND c.difficulty_level = 'Beginner' THEN 80.0
                WHEN c.difficulty_level = 'Beginner' THEN 75.0
                ELSE 60.0
            END as score,
            CONCAT('Recommended based on GPA: ', s.current_gpa, 
                   ', Course difficulty: ', c.difficulty_level,
                   ', Department match: ', 
                   CASE WHEN s.department_id = c.department_id THEN 'Yes' ELSE 'No' END) as reason
        FROM courses c
        CROSS JOIN students s
        WHERE s.student_id = student_id_param
        AND c.course_id NOT IN (
            -- Exclude already completed courses
            SELECT course_id FROM course_grades WHERE student_id = student_id_param
            UNION
            -- Exclude currently enrolled courses
            SELECT course_id FROM enrollments 
            WHERE student_id = student_id_param AND status = 'Enrolled'
        )
        AND (
            -- Check prerequisites are met
            c.course_id NOT IN (
                SELECT DISTINCT cp.course_id 
                FROM course_prerequisites cp
                WHERE cp.course_id = c.course_id
                AND cp.prerequisite_course_id NOT IN (
                    SELECT course_id FROM course_grades 
                    WHERE student_id = student_id_param AND grade_points >= 2.0
                )
            )
            OR 
            c.course_id NOT IN (SELECT course_id FROM course_prerequisites)
        )
        ORDER BY score DESC
        LIMIT 5;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN course_cursor;
    
    read_loop: LOOP
        FETCH course_cursor INTO course_id_var, recommendation_score_var, reason_var;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        INSERT INTO student_recommendations 
        (student_id, recommended_course_id, recommendation_score, reason, semester, year, is_active)
        VALUES 
        (student_id_param, course_id_var, recommendation_score_var, reason_var, 'Fall', 2024, TRUE);
    END LOOP;
    
    CLOSE course_cursor;
END//

-- 4. Stored Procedure to get course prerequisite chains (Recursive CTE simulation)
CREATE PROCEDURE GetPrerequisiteChain(IN course_id_param INT)
BEGIN
    -- Create temporary table for recursive results
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_prerequisites (
        level_num INT,
        course_id INT,
        course_name VARCHAR(200),
        prerequisite_id INT,
        prerequisite_name VARCHAR(200)
    );
    
    -- Clear previous results
    DELETE FROM temp_prerequisites;
    
    -- Level 0: Direct prerequisites
    INSERT INTO temp_prerequisites (level_num, course_id, course_name, prerequisite_id, prerequisite_name)
    SELECT 
        0 as level_num,
        c1.course_id,
        c1.course_name,
        c2.course_id as prerequisite_id,
        c2.course_name as prerequisite_name
    FROM courses c1
    JOIN course_prerequisites cp ON c1.course_id = cp.course_id
    JOIN courses c2 ON cp.prerequisite_course_id = c2.course_id
    WHERE c1.course_id = course_id_param;
    
    -- Level 1: Prerequisites of prerequisites (simplified recursion)
    INSERT INTO temp_prerequisites (level_num, course_id, course_name, prerequisite_id, prerequisite_name)
    SELECT DISTINCT
        1 as level_num,
        tp.prerequisite_id,
        tp.prerequisite_name,
        c2.course_id as prerequisite_id,
        c2.course_name as prerequisite_name
    FROM temp_prerequisites tp
    JOIN course_prerequisites cp ON tp.prerequisite_id = cp.course_id
    JOIN courses c2 ON cp.prerequisite_course_id = c2.course_id
    WHERE tp.level_num = 0
    AND c2.course_id NOT IN (SELECT DISTINCT prerequisite_id FROM temp_prerequisites);
    
    -- Return the prerequisite chain
    SELECT * FROM temp_prerequisites ORDER BY level_num, course_name;
    
    DROP TEMPORARY TABLE temp_prerequisites;
END//

DELIMITER ;

-- Generate recommendations for all active students
DELIMITER //
CREATE PROCEDURE GenerateAllRecommendations()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE student_id_var INT;
    
    DECLARE student_cursor CURSOR FOR
        SELECT student_id FROM students WHERE status = 'Active';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN student_cursor;
    
    read_loop: LOOP
        FETCH student_cursor INTO student_id_var;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        CALL GenerateCourseRecommendations(student_id_var);
    END LOOP;
    
    CLOSE student_cursor;
END//
DELIMITER ;

-- Execute the recommendation generation
CALL GenerateAllRecommendations();