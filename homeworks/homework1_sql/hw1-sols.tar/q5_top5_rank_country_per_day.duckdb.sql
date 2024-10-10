-- 问题：对于每一天，找出在当天前5名（包括第5名）中出现次数最多的国家。
-- 对于这些国家，还要列出它们的人口排名和GDP排名。按日期升序排序输出结果。

-- 详细要求：
-- 1. 只考虑 `results` 表中 `rank` 不为空的记录来计算出现次数。
-- 2. 排除所有 `rank` 值都为空的日期。
-- 3. 如果出现次数相同，选择字母顺序靠前的国家。
-- 4. 保持日期的原始格式。
-- 5. 使用 `result` 表，并使用 `participant_code` 获取相应的国家。
-- 6. 如果无法获取 `result` 表中某条记录的国家信息，忽略该记录。

-- 输出格式：DATE|COUNTRY_CODE|TOP5_APPEARANCES|GDP_RANK|POPULATION_RANK

-- 创建临时表 t，用于存储团队代码和国家代码的对应关系
with t as (
	select code, country_code from teams group by code, country_code
),
-- 创建临时表 country_rank，用于计算每个国家的GDP排名和人口排名
country_rank as (
select
    code,
    rank() over (order by "GDP ($ per capita)" desc) as gdp_rank,
    rank() over (ORDER BY "Population" desc) as population_rank
from
    countries
)

-- 主查询
select 
    date, 
    country as country_code, 
    num as top5_appearances, 
    country_rank.gdp_rank as gdp_rank, 
    country_rank.population_rank as population_rank
from
    (select 
        *,
        -- 为每个日期的国家按出现次数降序和国家代码升序排序
        row_number() over (partition by date order by num desc, country) as row_number
    from
        (select 
            date, 
            -- 优先使用团队的国家代码，如果没有则使用运动员的国家代码
            case when t1.country_code is not null then t1.country_code else athletes.country_code end as country, 
            count(*) as num
        from 
            -- 将results表与团队表t关联，以获取团队的国家代码
            (select * from results left join t on results.participant_code = t.code) 
            as t1 
            -- 再与athletes表关联，以获取个人运动员的国家代码
            left join athletes on t1.participant_code = athletes.code
        where rank <= 5  -- 只考虑前5名
        group by date, country)
    ) as t, country_rank
where row_number = 1 and country_rank.code = t.country  -- 选择每天出现次数最多的国家，并关联国家排名信息
order by date;  -- 按日期升序排序
