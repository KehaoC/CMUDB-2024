with new_results as (
select DISTINCT
r.date, r.rank, r.participant_type, r.event_name, r.discipline_name, r.participant_code,
COALESCE(a.country_code, t.country_code) as country_code
from results r
left join teams t on r.participant_code = t.code
left join athletes a on r.participant_code = a.code
where r.rank <= 5
and r.rank is not null
),
country_appearance as (
select nr.date, nr.country_code, count(*) as TOP5_APPEARANCE
from new_results nr
group by nr.date, nr.country_code
order by date, TOP5_APPEARANCE desc
)
select date, country_code, TOP5_APPEARANCE, gdp_rank as GDP_RANK, population_rank as POPULATION_RANK
from(
    select *, 
    row_number() over (partition by date order by TOP5_APPEARANCE desc) as rank
    from country_appearance
)
inner join (
    select code, 
    rank() over (order by "GDP ($ per capita)" desc) as gdp_rank,
    rank() over (order by "Population" desc) as population_rank
    from countries
) as country_rank
on country_code = country_rank.code
where rank == 1
limit 10;

select code, 
rank() over (order by "GDP ($ per capita)" desc) as gdp_rank,
rank() over (order by "Population" desc) as population_rank
from countries
limit 10;