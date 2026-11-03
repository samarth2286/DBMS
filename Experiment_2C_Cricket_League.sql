CREATE DATABASE CricketLeague;
USE CricketLeague;

CREATE TABLE Team (
    team_id VARCHAR(5) PRIMARY KEY,
    team_name VARCHAR(50),
    city VARCHAR(30)
);

CREATE TABLE Player (
    player_id INT PRIMARY KEY,
    name VARCHAR(30),
    team_id VARCHAR(5),
    role VARCHAR(20),
    FOREIGN KEY (team_id) REFERENCES Team(team_id)
);

CREATE TABLE Performance (
    match_no INT,
    player_id INT,
    runs INT,
    balls INT,
    wickets INT,
    PRIMARY KEY (match_no, player_id),
    FOREIGN KEY (player_id) REFERENCES Player(player_id)
);

INSERT INTO Team VALUES
('T1', 'Sangli Strikers', 'Sangli'),
('T2', 'Pune Panthers', 'Pune'),
('T3', 'Kolhapur Kings', 'Kolhapur');

INSERT INTO Player VALUES
(1, 'Ishan', 'T1', 'Batter'),
(2, 'Yash', 'T1', 'Bowler'),
(3, 'Mihir', 'T2', 'Batter'),
(4, 'Om', 'T2', 'All-rounder'),
(5, 'Rutuja', 'T3', 'Batter'),
(6, 'Soham', 'T3', 'Bowler'),
(7, 'Parth', 'T1', 'All-rounder');

INSERT INTO Performance VALUES
(1, 1, 72, 48, 0),
(1, 2, 5, 6, 3),
(1, 3, 40, 35, 0),
(1, 4, 28, 20, 2),
(2, 1, 15, 18, 0),
(2, 5, 88, 55, 0),
(2, 6, 2, 4, 4),
(3, 3, 65, 40, 0),
(3, 4, 10, 8, 1),
(3, 6, 0, 1, 2);


-- Q1
SELECT p.name AS player_name, t.team_name, pf.runs
FROM Performance pf
INNER JOIN Player p
ON pf.player_id = p.player_id
INNER JOIN Team t
ON p.team_id = t.team_id;


-- Q2
SELECT p.player_id, p.name,
       COALESCE(SUM(pf.runs), 0) AS total_runs
FROM Player p
LEFT JOIN Performance pf
ON p.player_id = pf.player_id
GROUP BY p.player_id, p.name;


-- Q3
SELECT t.team_id, t.team_name,
       SUM(pf.runs) AS total_runs
FROM Team t
INNER JOIN Player p
ON t.team_id = p.team_id
INNER JOIN Performance pf
ON p.player_id = pf.player_id
GROUP BY t.team_id, t.team_name
HAVING SUM(pf.runs) > 100;


-- Q4
SELECT p.player_id, p.name,
       MAX(pf.runs) AS highest_score
FROM Player p
INNER JOIN Performance pf
ON p.player_id = pf.player_id
GROUP BY p.player_id, p.name
ORDER BY highest_score DESC
LIMIT 1;


-- Q5
SELECT DISTINCT p.player_id, p.name
FROM Player p
INNER JOIN Performance pf
ON p.player_id = pf.player_id
WHERE pf.wickets >= 2;


-- Q6
SELECT p.player_id, p.name
FROM Player p
LEFT JOIN Performance pf
ON p.player_id = pf.player_id
WHERE pf.player_id IS NULL;


-- Q7
SELECT DISTINCT p.player_id, p.name
FROM Player p
WHERE p.player_id IN (
    SELECT player_id
    FROM Performance
    WHERE runs > (
        SELECT AVG(runs)
        FROM Performance
    )
);


-- Q8
SELECT t.team_id, t.team_name,
       COUNT(p.player_id) AS total_players
FROM Team t
LEFT JOIN Player p
ON t.team_id = p.team_id
GROUP BY t.team_id, t.team_name;


-- Q9
CREATE VIEW top_batters AS
SELECT p.player_id, p.name,
       SUM(pf.runs) AS total_runs
FROM Player p
INNER JOIN Performance pf
ON p.player_id = pf.player_id
GROUP BY p.player_id, p.name
HAVING SUM(pf.runs) > 50;

SELECT * FROM top_batters;


-- Q10
SELECT p.player_id, p.name,
       COALESCE(SUM(pf.wickets), 0) AS total_wickets
FROM Player p
LEFT JOIN Performance pf
ON p.player_id = pf.player_id
GROUP BY p.player_id, p.name
ORDER BY total_wickets DESC;
