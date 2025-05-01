-- Netflix Table 
Select * from Netflix  

-- Data analysis of Netflix's Business Problems 

-- 1. Count the number of Movies vs TV Shows

	Select Type, Count(Type) Content_count from Netflix
	Group By Type
	


-- 2. Find the most common rating for movies and TV shows

   With RatingCounts AS (
     Select Type, Rating, Count(Rating) rating_count
	 from Netflix
	 Group by Type, Rating
   ),
   RankedRatings As (
     Select Type, Rating, rating_count, Rank() over (Partition by type order by rating_count desc) as rank
	 from RatingCounts
   )
   Select type, rating from RankedRatings
   where rank = 1



-- 3. List all movies released in a specific year (e.g., 2020)

   Select title from Netflix
   where release_year = 2020 and type = 'Movie'


-- 4. Find the top 5 countries with the most content on Netflix

   Select countries 
   from (
       Select 
	   Trim(Unnest(STRING_TO_ARRAY(country, ','))) countries, 
	   Count(show_id) Showno
	   from Netflix
	   group by countries
	   order by Showno desc
   )
   Limit 5

-- 5. Identify the longest movie

    Select title Longest_Movie from Netflix
	where type = 'Movie' 
	and 
	duration is not null
	order by SPLIT_PART(duration, ' ', 1)::INT desc
	Limit 1


-- 6. Find content added in the last 5 years

    Select * from Netflix
	where TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - Interval '5 years'

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

    Select * from (
        Select *, TRIM(UNNEST(STRING_TO_ARRAY(director, ', '))) as director_name from Netflix
	)
	where director_name = 'Rajiv Chilaka'

-- 8. List all TV shows with more than 5 seasons

	Select * from Netflix 
	where type = 'TV Show' and 
	SPLIT_PART(duration, ' ', 1)::INT > 5

-- 9. Count the number of content items in each genre


	Select TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) as Genre, 
	Count(show_id) as Content 
	from Netflix
	group by 1
	order by 1
		


-- 10.Find each year and the average numbers of content release in India on netflix. 
-- Return top 5 year with highest avg content release!

	
	With CountryRelease as (
		Select 
		-- show_id,
		release_year,
		Trim(Unnest(STRING_TO_ARRAY(country, ','))) as country_name,
		count(show_id) content_number
		-- show_id
		from Netflix
		group by 1,2
		order by 3 desc
	)	
	SELECT 
	country_name,
	release_year,
	SUM(content_number) as total_release,
	ROUND(
		SUM(content_number)::numeric/
								(SELECT SUM(content_number) FROM CountryRelease WHERE country_name = 'India')::numeric * 100 
		,2
		)
		as avg_release
	FROM CountryRelease
	WHERE country_name = 'India' 
	GROUP BY country_name, 2
	ORDER BY avg_release DESC 
	LIMIT 5


-- 11. List all movies that are documentaries

	Select * from Netflix
	where listed_in like '%Documentaries%' and type = 'Movie'


-- 12. Find all content without a 

	Select * from netflix 
	where Director is null


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

	Select * from Netflix 
	where casts like '%Salman Khan%' and
	release_year > EXTRACT(YEAR from CURRENT_DATE ) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

	Select TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) as Casts, 
	count(show_id) as Movies_Appeared
	from Netflix 
	where country like '%India%' and type = 'Movie' and casts is not null
	group by 1
	order by 2 DESC
	LIMIT 10


-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

	Select Type, Category, Count(show_id) from
	(
		Select *,
		CASE
			When description like '%kill%' or description like '%violence%'
			THEN 'Bad'
			ELSE 'Good'
		END as Category
		from Netflix
		
	) AS categorized_content

	group by 1,2
	order by 3

