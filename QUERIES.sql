--1

SELECT CLASS_TYPE AS CLASS_LIST,
(SELECT FIRST_NAME ||' '|| LAST_NAME FROM STAFF WHERE STAFF_ID = FITNESS_CLASSES.INSTRUCTOR_ID) AS INSTRUCTOR_NAME, 
TO_CHAR(SCHEDULE,'DD-MON-YYYY HH24:MI') AS SCHEDULE
FROM FITNESS_CLASSES
ORDER BY CLASS_LIST;

--2

SELECT CLIENTS.FIRST_NAME || ' ' || CLIENTS.LAST_NAME AS CLIENT_NAME, CLASS_BOOKINGS.STATUS
FROM FITNESS_CLASSES
JOIN CLASS_BOOKINGS ON FITNESS_CLASSES.CLASS_ID = CLASS_BOOKINGS.CLASS_ID
JOIN CLIENTS ON CLASS_BOOKINGS.CLIENT_ID = CLIENTS.CLIENT_ID
WHERE FITNESS_CLASSES.CLASS_TYPE = 'Yoga';

--3

SELECT SUM(AMOUNT) AS TOTAL_REVENUE
FROM BILLING
WHERE SERVICE_NAME IN ('Membership', 'Class Booking', 'Personal Training');

--4

SELECT TRAINER_ID, COUNT(TRAINING_ID) AS SESSIONS_TAKEN
FROM PERSONAL_TRAINING_SESSIONS
GROUP BY TRAINER_ID
ORDER BY TRAINER_ID
FETCH FIRST 5 ROWS ONLY;

--5

SELECT CL.FIRST_NAME || ' ' || CL.LAST_NAME AS CLIENT_NAME, CL.CLIENT_ID
FROM GYM_ATTENDANCE GA
JOIN MEMBERSHIP MEM ON MEM.CLIENT_ID = GA.CLIENT_ID
JOIN CLIENTS CL ON GA.CLIENT_ID = CL.CLIENT_ID
WHERE MEM.END_DATE < SYSDATE AND GA.CHECK_IN > SYSDATE - 30;

--6

SELECT CLIENT_ID, COUNT(EXERCISE_TYPE) AS EXERCISE
FROM PERSONAL_TRAINING_SESSIONS
GROUP BY CLIENT_ID
HAVING COUNT(EXERCISE_TYPE) >= 3
ORDER BY EXERCISE;