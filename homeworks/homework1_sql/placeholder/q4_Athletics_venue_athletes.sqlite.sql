-- All venues that host Athletics displines
select * from venues 
where disciplines like '%Athletics%';

-- all athletes who have competed at these venues
-- 只有个人
select a.name, r.venue, r.discipline_name from athletes a 
join results r
on a.code = r.participant_code
where r.venue in (
    select venue from venues 
    where disciplines like '%Athletics%'
)
order by random()
limit 5;

-- 只有团队
select a.name, t.team, r.venue from teams t
join athletes a
on t.athletes_code = a.code
join results r
on t.code = r.participant_code
where r.venue in (
    select venue from venues 
    where disciplines like '%Athletics%'
)
order by random()
limit 5;

-- 合并团队和个人
select a.name, a.country_code, a.nationality_code from athletes a 
join results r
on a.code = r.participant_code
where r.venue in (
    select venue from venues 
    where disciplines like '%Athletics%'
)
UNION
select a.name, a.country_code, a.nationality_code from teams t
join athletes a
on t.athletes_code = a.code
join results r
on t.code = r.participant_code
where r.venue in (
    select venue from venues 
    where disciplines like '%Athletics%'
);

-- 收集所有人的人名，国家国籍的距离信息
WITH athletics_participants AS (
    select a.name, a.country_code, a.nationality_code from athletes a 
    join results r
    on a.code = r.participant_code
    where r.venue in (
        select venue from venues 
        where disciplines like '%Athletics%'
    )
    UNION
    select a.name, a.country_code, a.nationality_code from teams t
    join athletes a
    on t.athletes_code = a.code
    join results r
    on t.code = r.participant_code
    where r.venue in (
        select venue from venues 
        where disciplines like '%Athletics%'
    )
)
select ap.name name, 
ap.country_code country_code,
ap.nationality_code nationality_code,
c.Latitude country_latitude, c.Longitude country_longitude,
c2.Latitude nationality_latitude, c2.Longitude nationality_longitude,
power(c.Latitude - c2.Latitude, 2) + power(c.Longitude - c2.Longitude, 2) distance
from athletics_participants ap 
join countries c
on ap.country_code = c.code
join countries c2
on ap.nationality_code = c2.code
where ap.name is not NULL
and c.Latitude is not NULL
and c2.Latitude is not NULL
and c.Longitude is not NULL
and c2.Longitude is not NULL
limit 5;

-- 排序，输出结果
WITH athletics_participants AS (
    select a.name, a.country_code, a.nationality_code from athletes a 
    join results r
    on a.code = r.participant_code
    where r.venue in (
        select venue from venues 
        where disciplines like '%Athletics%'
    )
    UNION
    select a.name, a.country_code, a.nationality_code from teams t
    join athletes a
    on t.athletes_code = a.code
    join results r
    on t.code = r.participant_code
    where r.venue in (
        select venue from venues 
        where disciplines like '%Athletics%'
    )
)
select ap.name ATHLETE_NAME, 
ap.country_code REPRESENTED_COUNTRY_CODE,
ap.nationality_code NATIONALITY_COUNTRY_CODE
from athletics_participants ap 
join countries c
on ap.country_code = c.code
join countries c2
on ap.nationality_code = c2.code
where ap.name is not NULL
and c.Latitude is not NULL
and c2.Latitude is not NULL
and c.Longitude is not NULL
and c2.Longitude is not NULL
order by 
power(c.Latitude - c2.Latitude, 2) + power(c.Longitude - c2.Longitude, 2) desc,
name asc
limit 10;