create database if not exists db_ath;

use db_ath;

drop table if exists athelete;

create table if not exists athelete(id int, name varchar(30), sex char, age int, height int, weight int, team varchar(20),
NOC text, Games varchar(50), Year int, season varchar(20), city varchar(20), sport varchar(20), event varchar(20), medal text);

SET SQL_SAFE_UPDATES = 0;
LOAD DATA LOCAL INFILE 'FILEPATH'
INTO TABLE athlete
fields TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 rows;

-- explain analyze select count(*) from athlete;

select name, team, NOC, Games, season, city, sport, event, medal from athlete where
name is null  or team is null or NOC is null or Games is null or season is null or city
 is null or sport is null or event is null or medal is null;

select count(team), season from athlete group by season having season in ('summer', 'winter');

select distinct Sport from athlete;

select count(Event), season from athlete group by season having season in ('summer', 'winter');

select count(id), year from athlete where season = 'summer' group by year;

select count(id), year, season from athlete group by year, season having season in ('summer', 'winter');

select count(id),name, sport from athlete group by sport,name;

select distinct name, age from athlete order by age desc limit 10;

select distinct name, weight from athlete order by weight limit 10;

select age from athlete where medal like 'Gold' order by age limit 10 ;

select weight from athlete where medal like 'Gold' order by weight desc limit 10 ;

select weight from athlete where medal like 'G%' order by weight limit 10;

SELECT name, 
       COUNT(*) AS total, 
       SUM(CASE WHEN medal = 'gold' THEN 1 ELSE 0 END) AS gold, 
       SUM(CASE WHEN medal = 'silver' THEN 1 ELSE 0 END) AS silver, 
       SUM(CASE WHEN medal = 'bronze' THEN 1 ELSE 0 END) AS bronze
       FROM athlete
where medal <> 'NA'
GROUP BY name
ORDER BY total DESC
LIMIT 10;
select * from athlete;
select team,
	count(*) as total,
    sum(if(Medal like 'gold', 1, 0)) as gold,
    sum(if(Medal like 'silver', 1, 0)) as silver,
    sum(if(Medal like 'bronze', 1, 0)) as bronze
    from athlete where medal <> 'NA'
    group by team
    order by total desc
    limit 10;


select t1.year,t1.team,count(t1.medal) as medalsWon,TotalMedals,
(count(t1.medal)/TotalMedals)*100 as percent from athlete as t1
join (select year,count(medal) as TotalMedals from athlete group by year) as t2 on t1.year = t2.year
group by t1.year,t1.team 
order by 
percent desc
limit 5;

-- 19 
with temporaryTable(totalMedals) as (select count(medal) from athlete)
select distinct team
-- ,totalMedals,count(medal)
,(count(medal)/totalMedals)*100 as percent from athlete,temporaryTable 
where team in ("China","United States","Russia","Australia","Great Britain")
group by team,totalMedals order by percent desc;
