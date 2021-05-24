DROP PROCEDURE IF EXISTS `sp_prepare_data`;
CREATE PROCEDURE `sp_prepare_data`()
BEGIN
	INSERT INTO movies(movie_id, title, `year`, genres, rating)
    WITH RECURSIVE CTE_split_genres AS
    (
		SELECT movie_id, title, FN_SPLIT_STR(genres, '|', 1) as genre,
        IF(
			LOCATE('|', stg_movies.genres) > 0,
            SUBSTRING(stg_movies.genres, LOCATE('|', stg_movies.genres) + 1),
            ''
		) AS other_genres
        FROM stg_movies
        UNION ALL
        SELECT movie_id, title, FN_SPLIT_STR(other_genres, '|', 1),
        IF(
			LOCATE('|', other_genres) > 0,
            SUBSTRING(other_genres, LOCATE('|', other_genres) + 1),
            ''
		) AS other_genres
        FROM CTE_split_genres
        WHERE other_genres != ''
	),
    CTE_ratings AS
    (
		SELECT
			movie_id,
			AVG(stg_ratings.rating) AS average_rating
        FROM stg_ratings
        GROUP BY stg_ratings.movie_id
    )
    SELECT
		CTE_split_genres.movie_id,
        FN_GET_NAME_FROM_TITLE(title),
        FN_GET_YEAR_FROM_TITLE(title),
        genre,
        average_rating
	FROM CTE_split_genres
    LEFT JOIN CTE_ratings
    ON CTE_ratings.movie_id = CTE_split_genres.movie_id;
END