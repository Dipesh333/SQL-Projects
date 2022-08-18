
------Highest winning percentage by team-----

with  Total_Matches as 
(SELECT t.team ,COUNT(*)total_games FROM teams t JOIN Matches m on t.team=m.team1 or t.team=m.team2
GROUP BY t.team),

winning as (SELECT winner,COUNT(winner)Total_Wins FROM  Matches
GROUP BY winner)

SELECT t1.team,ROUND(w.Total_Wins*100.00/t1.total_games,2)Winning_Percentage FROM 
Total_Matches t1 join winning w on t1.team=w.winner
ORDER BY Winning_Percentage DESC

------Winning Percentage of team winning toss-------
WITH toss_match_win AS (SELECT t.team,COUNT(*)matches_win_after_winning_toss FROM teams t join  Matches m 
ON t.team=m.winner 
WHERE m.toss_winner=m.winner
GROUP BY t.team),

winning as (SELECT winner,COUNT(winner)total_wins FROM  Matches
GROUP BY winner)

SELECT t1.team,ROUND((matches_win_after_winning_toss*100.00/total_wins),2)'toss+match_win%'
FROM toss_match_win t1 JOIN winning t2 ON t1.team=t2.winner
ORDER BY [toss+match_win%] DESC

------Win Percentage of team after electing bat first--------
WITH matches_batting AS (SELECT t.team as team,COUNT(*)batting_first FROM teams t JOIN Matches m on t.team=m.team1 or t.team=m.team2 
WHERE win_by_runs>0
GROUP BY t.team),

bat_winning as (SELECT winner,COUNT(winner)total_wins FROM  Matches  
WHERE win_by_runs>0
GROUP BY winner) 

SELECT m.team, SUM(m.batting_first)batting_first,SUM(w.total_wins)total_wins,(SUM(w.total_wins)*100.0)/SUM(m.batting_first) bat_percentage 
FROM bat_winning w  JOIN matches_batting m ON m.team=w.winner 
GROUP BY m.team
ORDER BY bat_percentage DESC

------Win Percentage of team after electing bowl first--------

WITH matches_bowling AS (SELECT t.team as team,COUNT(*)bowling_first FROM teams t JOIN Matches m on t.team=m.team1 or t.team=m.team2 
WHERE win_by_wickets>0
GROUP BY t.team),

bowl_winning as (SELECT winner,COUNT(winner)total_wins FROM  Matches  
WHERE win_by_wickets>0
GROUP BY winner)

SELECT m.team, SUM(m.bowling_first)bowling_first,SUM(w.total_wins)total_wins,(SUM(w.total_wins)*100.0)/SUM(m.bowling_first)bowl_win_percentage 
FROM bowl_winning w  JOIN matches_bowling m ON m.team=w.winner 
GROUP BY m.team
ORDER BY bowl_win_percentage DESC

-----Largest margin of victory(by runs)
SELECT date,winner,win_by_runs FROM Matches
WHERE win_by_runs=(SELECT MAX(win_by_runs) FROM Matches)

-----Largest margin of victory(by wickets)
SELECT date,winner,win_by_wickets FROM Matches
WHERE win_by_wickets=(SELECT MAX(win_by_wickets) FROM Matches)

-----No. of tie matches----------
SELECT COUNT(result)tie_matches FROM MATCHES
WHERE result='tie'

-----winner declared by duckworth-lewis method----------
SELECT COUNT(dl_applied)dl_applied FROM MATCHES
WHERE dl_applied=1

-------Most no. of player of the match---------
SELECT player_of_match,COUNT(player_of_match)POM FROM Matches
GROUP BY player_of_match
ORDER BY POM DESC

------Venue with highest no. of matches played---------
SELECT venue,COUNT(venue)no_of_matches FROM Matches
GROUP BY venue
ORDER BY no_of_matches DESC

----Highest run scorers-------
SELECT batsman,SUM(batsman_runs)runs FROM Deliveries
GROUP BY batsman
ORDER BY runs DESC

----Highest wicket takers-------
SELECT bowler,COUNT(dismissal_kind)wickets FROM Deliveries
WHERE dismissal_kind IN ('bowled','caught','caught and bowled','hit wicket','lbw','stumped')
GROUP BY bowler
ORDER BY wickets DESC

-----IPL Season most no. of sixes-------
SELECT m.Season,COUNT(*)no_of_sixes FROM Deliveries d JOIN Matches m on d.match_id=m.id
WHERE d.batsman_runs>=6
GROUP BY m.Season
ORDER BY no_of_sixes DESC

-----Batsman who hit most no. of sixes by IPL Season-------
WITH cte as 
(
SELECT d.batsman,m.Season,COUNT(*)no_of_sixes FROM Deliveries d JOIN Matches m on d.match_id=m.id
WHERE d.batsman_runs>=6
GROUP BY m.Season,d.batsman
)
SELECT batsman,Season,no_of_sixes FROM 
(SELECT *,DENSE_RANK() OVER (PARTITION BY Season ORDER BY no_of_sixes DESC)derank FROM cte)a
WHERE a.derank=1

--------Highest scorer in each IPL Season-----------
WITH CTE AS (SELECT batsman,SUM(batsman_runs)runs,Season FROM Deliveries d JOIN Matches m on d.match_id=m.id
GROUP BY batsman,Season)
SELECT batsman,Season,runs FROM 
(SELECT *,DENSE_RANK() OVER (PARTITION BY Season ORDER BY runs DESC)derank FROM cte)a
WHERE a.derank=1

------Highest Wicket-taker in each IPL Season-----------
WITH CTE AS (SELECT bowler,COUNT(dismissal_kind)wickets,Season FROM Deliveries d JOIN Matches m on d.match_id=m.id
WHERE dismissal_kind IN ('bowled','caught','caught and bowled','hit wicket','lbw','stumped')
GROUP BY bowler,Season)
SELECT bowler,Season,wickets FROM 
(SELECT *,DENSE_RANK() OVER (PARTITION BY Season ORDER BY wickets DESC)derank FROM cte)a
WHERE a.derank=1

----Most runs in Death Overs(16-20)------
SELECT batsman,SUM(batsman_runs)runs FROM Deliveries
WHERE overs>15
GROUP BY batsman
ORDER BY runs DESC

----Highest Average in Death Overs(16-20)----
WITH CTE1 AS 
(SELECT batsman,SUM(batsman_runs)runs FROM Deliveries
WHERE overs>15
GROUP BY batsman),
CTE2 AS
(SELECT batsman,COUNT(player_dismissed)got_out FROM Deliveries
WHERE overs>15 AND player_dismissed=batsman
GROUP BY batsman)

SELECT c1.batsman,runs,got_out,(runs/got_out)Average FROM CTE1 c1 JOIN CTE2 c2 ON c1.batsman=c2.batsman
ORDER BY Average DESC

----Highest Strike Rate in Death Overs(16-20)----
SELECT batsman,SUM(batsman_runs)runs,COUNT(ball)balls,((SUM(batsman_runs)/COUNT(ball))*100)strike_rate FROM Deliveries
WHERE overs>15
GROUP BY batsman
ORDER BY runs DESC 

--------Bowlers record in Death Overs(16-20)---------
WITH CTE1 AS(
SELECT bowler,COUNT(dismissal_kind)wickets FROM Deliveries
WHERE dismissal_kind IN ('bowled','caught','caught and bowled','hit wicket','lbw','stumped') AND overs>15
GROUP BY bowler),
CTE2 AS
(
SELECT bowler,SUM(total_runs)runs_conceded,COUNT(ball)balls,ROUNd((COUNT(ball)/6.00),2)overs
FROM Deliveries
WHERE overs>15
GROUP BY bowler)

SELECT c1.bowler,wickets,runs_conceded,balls,overs,ROUND((runs_conceded/overs),2)economy_rate
FROM CTE1 c1 JOIN CTE2 c2 ON c1.bowler=c2.bowler
ORDER BY wickets DESC 

--------Batsman most score against any team---------
SELECT TOP 5 batsman,bowling_team,SUM(batsman_runs)runs FROM Deliveries
GROUP BY batsman,bowling_team
ORDER BY runs DESC

--------Longest streak without getting out on Zero---------
WITH CTE1 AS
( 
SELECT batsman,match_id,m.match_date,SUM(batsman_runs)runs FROM Deliveries d JOIN Matches m on d.match_id=m.id
GROUP BY batsman,match_id,m.match_date
),
CTE2 AS
(SELECT *, CASE WHEN runs=0 THEN 'Zero'
ELSE 'Non-Zero'
END AS 'Zero_Score'
FROM CTE1),
CTE3 AS
(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY batsman ORDER BY match_date ASC)row_number1,
ROW_NUMBER() OVER (PARTITION BY batsman,Zero_Score ORDER BY match_date ASC)row_number2,
(ROW_NUMBER() OVER (PARTITION BY batsman ORDER BY match_date ASC))-(ROW_NUMBER() OVER (PARTITION BY batsman,Zero_Score ORDER BY match_date ASC)) streak_id
FROM CTE2
ORDER BY batsman,match_date ASC
)
SELECT DISTINCT batsman,streak_length  
FROM (
SELECT batsman,Zero_Score AS streak_result,streak_id,COUNT(*) AS streak_length,RANK() OVER (ORDER BY COUNT(*) DESC) rnk
FROM CTE3
WHERE Zero_Score='Non-Zero'
GROUP BY batsman,streak_result,streak_id
ORDER BY batsman,streak_id)a
WHERE rnk=1

------------stored procedure for batsman vs bowler---------------
CREATE PROCEDURE BatvsBowl @batsman nvarchar(50),@bowler nvarchar(50)
AS

WITH CTE1 AS
(
SELECT batsman,bowler,SUM(batsman_runs)runs,COUNT(ball)balls FROM Deliveries
GROUP BY batsman,bowler
),
CTE2 AS 
(
SELECT batsman,bowler,COUNT(dismissal_kind)wickets FROM Deliveries
WHERE dismissal_kind IN ('bowled','caught','caught and bowled','hit wicket','lbw','stumped')
GROUP BY batsman ,bowler
)
SELECT c1.batsman,c1.bowler,runs,balls,wickets FROM CTE1 c1 JOIN CTE2 c2 ON c1.batsman=c2.batsman AND c1.bowler=c2.bowler
WHERE c1.batsman=@batsman AND c1.bowler=@bowler
GO

EXEC BatvsBowl @batsman = 'AB de Villiers', @bowler = 'JJ Bumrah';

----------Batsman vs bowler with various skills--------------
WITH CTE1 AS 
(SELECT batsman,Bowling_Skill,SUM(batsman_runs)runs,COUNT(ball)balls  FROM Deliveries d JOIN Players p ON d.bowler=p.Player_Name
GROUP BY batsman,Bowling_Skill
),
CTE2 AS 
(
SELECT batsman,Bowling_Skill,COUNT(dismissal_kind)wickets FROM Deliveries d JOIN Players p ON d.bowler=p.Player_Name
WHERE dismissal_kind IN ('bowled','caught','caught and bowled','hit wicket','lbw','stumped')
GROUP BY batsman,Bowling_Skill
)
SELECT c1.batsman,c1.Bowling_Skill,balls,runs,wickets,(ROUND(((runs/balls)*100),2))strike_rate,ROUND((runs/wickets),2)average
FROM CTE1 c1 JOIN CTE2 c2 ON c1.batsman=c2.batsman AND c1.Bowling_Skill=c2.Bowling_Skill
WHERE c1.batsman='AB de Villiers'




