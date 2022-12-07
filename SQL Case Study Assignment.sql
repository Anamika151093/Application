USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/

-- Segment 1:

-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
SELECT Count(*) as count_director_mapping FROM director_mapping;
SELECT Count(*) as count_genre FROM genre;
SELECT Count(*) as count_names FROM  names;
SELECT Count(*) as count_ratings FROM ratings;
SELECT Count(*) as count_role_mapping FROM  role_mapping;


-- Q2. Which columns in the movie table have null values?
-- Type your code below:
SELECT 
    SUM(ISNULL(id)) AS id_null_count,
    SUM(ISNULL(title)) AS title_null_count,
    SUM(ISNULL(year)) AS year_null_count,
    SUM(ISNULL(date_published)) AS date_pub_null_count,
    SUM(ISNULL(duration)) AS duration_null_count,
    SUM(ISNULL(country)) AS country_null_count,
    SUM(ISNULL(worlwide_gross_income)) AS worl_gross_inc_null_count,
    SUM(ISNULL(languages)) AS languages_null_count,
    SUM(ISNULL(production_company)) AS prod_comp_null_count
FROM
    movie;

/*We see below null value columns in movie table
country ---20 null values
worlwide_gross_income---3724 values
languages---194 values
production_company---528 values*/

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

/*total number of movies released each year*/
SELECT 
    year AS Year, COUNT(id) AS number_of_movies
FROM
    movie
GROUP BY year
ORDER BY year;


/*monthwise trend*/
SELECT 
    MONTH(date_published) AS month_num,
    COUNT(id) AS number_of_movies
FROM
    movie
GROUP BY MONTH(date_published)
ORDER BY MONTH(date_published);

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:


/*We can see there could be movies that were produced in different countries with one of the country being
either India or USA , to include those movies we are using "regexp"*/

SELECT 
    COUNT(id) AS movie_count, year
FROM
    movie
WHERE
    country REGEXP 'India'
        OR country REGEXP 'USA'
GROUP BY year
HAVING year = 2019;
/*Observation-- 1059 movies produced by India and USA*/

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
SELECT distinct genre from genre;
/* Observation--There are 13 distinct genre of movies in the dataset*/

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:
SELECT 
    COUNT(g.movie_id) AS num_of_movies, g.genre
FROM
    genre g
        INNER JOIN
    movie m ON g.movie_id = m.id
GROUP BY genre
ORDER BY COUNT(g.movie_id) DESC
LIMIT 1;

/* Observation--We can see that Drama genre has the max number of movies(4285) produced in the dataset*/


/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

/*select count(movie_id) from genre;--14662
select count(id) from movie;--7997
We can see number of entries in both the tables are different.
Hence we do a join for the tables.*/


SELECT 
    COUNT(movie_id) AS count_movie_1_genre
FROM
    genre
WHERE
    movie_id IN (SELECT 
            g.movie_id
        FROM
            genre g
                INNER JOIN
            movie m ON m.id = g.movie_id
        GROUP BY g.movie_id
        HAVING COUNT(g.genre) = 1);

/*Observation-- We can see there are 3289 movies which has only one associated genre*/


/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
    genre, ROUND(AVG(m.duration), 2) AS avg_duration
FROM
    movie m
        INNER JOIN
    genre g ON g.movie_id = m.id
GROUP BY genre
ORDER BY avg_duration DESC;

/*We have rounded off the value of avg_duration to two places and
 arranged the values in descending order of the duration value*/


/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

with rank_CTE as 
(select g.genre, count(g.movie_id) ,
RANK() OVER (ORDER by count(movie_id) desc) as genre_rank
from genre g inner join movie m on m.id = g.movie_id 
group by genre)
SELECT * from rank_CTE where genre = "thriller" ;

/*Thriller--1484--3*/

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/

-- Segment 2:


-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:
SELECT 
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM
    ratings;

/*Observation: 
Minimum value of Average Rating column: 1.0
Maximum value of Average Rating column: 10.0
Minimum value of Total Votes column: 100
Maximum value of Total Votes column: 725138
Minimum value of Median Rating: 1
Maximum value of Median Rating: 10*/

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

/* We know using ROW_NUMBER rank function will return us unique ranks for unique films unlike RANK() or
DENSE_RANK() functions hence we are using ROW_NUMBER() rank function to determine a unique TOP 10 list
of movies based on its average ratings*/

WITH movie_rank_ct AS
(
SELECT m.title AS title,
      r.avg_rating as avg_rating,
      ROW_NUMBER() OVER (ORDER BY r.avg_rating DESC) as movie_rank
FROM movie AS m
INNER JOIN ratings AS r
ON m.id = r.movie_id
)
SELECT *
FROM movie_rank_ct
WHERE movie_rank <= 10;


/* Observation: Using row_number rank function we see Kirket at rank 1 and Shibu with rank 10. 
Fan has rank 5*/

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have
SELECT 
    median_rating, COUNT(movie_id) AS movie_count
FROM
    ratings
GROUP BY median_rating
ORDER BY COUNT(movie_id) DESC;

-- Observation: Movies with a median rating of 7 are highest in number (2257)

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

/* Once again we will use the ROW_NUMBER function as it will return as unique ranks*/

SELECT m.production_company AS production_company,
      COUNT(id)AS movie_count,
      ROW_NUMBER () OVER (ORDER BY COUNT(id) DESC) as prod_company_rank
FROM movie as m
INNER JOIN ratings as r
ON m.id = r.movie_id
WHERE r.avg_rating > 8 AND m.production_company IS NOT NULL
GROUP BY m.production_company;

/* Observation: Both Dream Warrior Pictures and National Theatre Live have same number of hit movies
i.e. 3, but since we have used ROW_NUMBER function to return unique ranks, Dream Warrior Pictures is the
top ranked production house with more hit movies having avg_rating > 8.*/


-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
    g.genre AS genre, COUNT(m.id) AS movie_count
FROM
    genre AS g
        INNER JOIN
    movie AS m ON g.movie_id = m.id
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
WHERE
    MONTH(m.date_published) = 3
        AND m.year = 2017
        AND m.country LIKE '%USA%'
        AND r.total_votes > 1000
GROUP BY g.genre
ORDER BY COUNT(m.id) DESC;
     
/* Observation: Drama genre has most movies i.e. 24 released during MARCH 2017 in USA having more than
1000 votes.*/


-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT 
    m.title AS title,
    r.avg_rating AS avg_rating,
    g.genre AS genre
FROM
    genre AS g
        INNER JOIN
    movie AS m ON g.movie_id = m.id
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
WHERE
    m.title LIKE 'The%' AND r.avg_rating > 8
ORDER BY avg_rating DESC;

/*Observation: There are 15 movies in total from all genre which have avg_rating > 8 and begin with the
letters "The" wherein The Brighton Miracle is the highest rated with rating of 9.5.*/

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT 
    r.median_rating, COUNT(r.movie_id) AS movie_count
FROM
    ratings AS r
        INNER JOIN
    movie AS m ON r.movie_id = m.id
WHERE
    m.date_published BETWEEN '2018-04-01' AND '2019-04-01'
        AND r.median_rating = 8;

/*Observation: There were a total of 361 movies between 1 April 2018 and 1 April 2019 which were 
given a median rating of 8.*/

       
-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

SELECT 
    m.country, SUM(r.total_votes) AS total_vote_count
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
WHERE
    m.country = 'Germany'
        OR m.country = 'Italy'
GROUP BY m.country;

-/*Observation: Answer to above question is YES, German movies get more votes than Italian movies.
German_votes--106710
Italy--77965*/

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/


-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT 
    SUM(ISNULL(name)) AS name_nulls,
    SUM(ISNULL(height)) AS height_nulls,
    SUM(ISNULL(date_of_birth)) AS date_of_birth_nulls,
    SUM(ISNULL(known_for_movies)) AS known_for_movies_nulls
FROM
    names;

/* Observation:
i. There are no null values in name column.
ii. There are 17335 null values in height column.
iii. There are 13431 null values in date_of_birth column.
iv. There are 15226 null values in known_for_movies column.*/


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH genre_top_ct
AS
(
SELECT
g.genre,
COUNT(g.movie_id) AS movie_count
FROM genre AS g
INNER JOIN ratings AS r
ON g.movie_id = r.movie_id
WHERE avg_rating>8
GROUP BY genre
ORDER BY movie_count DESC
LIMIT 3
),
director_top_ct
AS
(
SELECT
n.name AS director_name,
COUNT(dm.movie_id) AS movie_count,
RANK() OVER(ORDER BY COUNT(dm.movie_id) DESC) AS director_rank
FROM names AS n
INNER JOIN director_mapping AS dm
ON n.id = dm.name_id
INNER JOIN ratings AS r
ON r.movie_id = dm.movie_id
INNER JOIN genre AS g
ON g.movie_id = dm.movie_id,
genre_top_ct
WHERE r.avg_rating > 8 AND g.genre IN (genre_top_ct.genre)
GROUP BY n.name
ORDER BY movie_count DESC
)
SELECT director_name,
movie_count
FROM director_top_ct
WHERE director_rank <= 3
LIMIT 3;

/*Observation: Top 3 director in top 3 genre are James Mangold, Soubin Shahir and Joe Russo.*/

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
    n.name AS actor_name, COUNT(rm.movie_id) AS movie_count
FROM
    role_mapping AS rm
        INNER JOIN
    names AS n ON rm.name_id = n.id
        INNER JOIN
    ratings AS r ON rm.movie_id = r.movie_id
WHERE
    rm.category = 'Actor'
        AND r.median_rating >= 8
GROUP BY n.name
ORDER BY COUNT(rm.movie_id) DESC
LIMIT 2;


/*Observation: Mammootty with 8 and Mohanlal with 5 are the top 2 actors with median_rating> 8*/

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT m.production_company AS production_company,
	  SUM(r.total_votes) AS vote_count,
      RANK() OVER(ORDER BY SUM(r.total_votes) DESC) AS prod_comp_rank
FROM movie AS m
INNER JOIN ratings AS r
ON m.id = r.movie_id
GROUP BY m.production_company
limit 3;
  
/*Observation: Based on total number of votes Marvel Studios, Twentieth Century Fox and Warner Bros. finish in the 
TOP 3 position respectively.*/

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
SELECT n.name AS actor_name,
       r.total_votes AS total_votes,
       COUNT(r.movie_id) AS movie_count,
       ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) AS actor_avg_rating,
		RANK() OVER(order by ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2)desc,r.total_votes desc) AS actor_rank
FROM names AS n
INNER JOIN role_mapping AS rm
ON n.id = rm.name_id
INNER JOIN ratings AS r
ON rm.movie_id = r.movie_id
INNER JOIN movie AS m
ON m.id = r.movie_id
WHERE rm.category = "Actor" AND country = "India"
GROUP BY n.name
HAVING COUNT(r.movie_id) >= 5
limit 1;

/*Observation: Vijay Sethupathi is the actor with the highest rating in India amongst actors who have
worked in atleast 5 movies with a rating of 8.42*/

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT n.name AS actress_name,
       r.total_votes AS total_votes,
       COUNT(r.movie_id) AS movie_count,
       ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) AS actress_avg_rating,
       RANK() OVER(order by ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2)desc,r.total_votes desc) AS actress_rank
FROM names AS n
INNER JOIN role_mapping AS rm
ON n.id = rm.name_id
INNER JOIN ratings AS r
ON rm.movie_id = r.movie_id
INNER JOIN movie AS m
ON m.id = r.movie_id
WHERE rm.category = "Actress" AND m.country = "India" AND m.languages = "Hindi"
GROUP BY n.name
HAVING COUNT(r.movie_id) >= 3
limit 5;

/* Observation: Taapsee Pannu with a rating of 7.74 is the highest rated actress of hindi language movies released 
in India amongst actresses having done atleast 3 movies.*/

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:
SELECT 
    m.title,
    g.genre,
    r.avg_rating,
    CASE
        WHEN r.avg_rating > 8 THEN 'Superhit movies'
        WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
        WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
        ELSE 'Flop movies'
    END AS rating_classification
FROM
    genre AS g
        INNER JOIN
    movie AS m ON g.movie_id = m.id
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
WHERE
    g.genre = 'Thriller'
ORDER BY r.avg_rating DESC;

   
/* Observation: Amongst thriller movies, "Safe" is the biggest superhit movie with a rating of 9.5 while
9 films- Fahrenheit 451, Angelica, Stockholm, Paralytic, Night Pulse, Baadshaho, Perfect sanatos, 
The Child Remains and M/M are some of the biggest flops-all having a rating of 4.9*/


/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
SELECT genre,
       ROUND(AVG(duration),2) AS avg_duration,
       SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
       ROUND(AVG(AVG(duration)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING),2) AS moving_avg_duration
FROM movie AS m 
INNER JOIN genre AS g 
ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;








-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- Shatamanam Bhavati,Winner,Thank You for Your Service,The Healer and Gi-eok-ui bam are five  highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH top3_genre
AS
(
SELECT
genre,
COUNT(movie_id) as movie_count
FROM genre
GROUP BY genre
ORDER BY movie_count DESC
LIMIT 3
),
top5_movie
AS
(
SELECT
genre,
YEAR,
title as movie_name,
worlwide_gross_income,
RANK() OVER (PARTITION BY g.genre, year
					ORDER BY CONVERT(REPLACE(TRIM(worlwide_gross_income), "$ ",""), UNSIGNED INT) DESC) AS movie_rank
FROM movie m
INNER JOIN genre g
ON m.id = g.movie_id
WHERE genre IN(SELECT genre FROM top3_genre)
)
SELECT *
FROM top5_movie
WHERE movie_rank<=5;
 
-- Top 3 Genres based on most number of movies
-- Drama, comedy and Thriller are the top 3 genere based on most number of movies


-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
with production_company_detail
     AS (SELECT production_company,
                Count(*) AS movie_count
         FROM movie AS mov
                INNER JOIN ratings AS rat
		      ON rat.movie_id = mov.id
         WHERE median_rating >= 8
	       AND production_company IS NOT NULL
               AND Position(',' IN languages) > 0
         GROUP BY production_company
         ORDER BY movie_count DESC)
SELECT *,
       Rank() over( ORDER BY movie_count DESC) AS prod_comp_rank
FROM production_company_detail LIMIT 2;


-- Star Cinema and Twentieth Century Fox are the top 2 production houses that have produced the highest number of hits.




-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH actress_summary 
     AS( SELECT n.name AS actress_name,
                SUM(total_votes) AS total_votes,
		Count(r.movie_id) AS movie_count,
                Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating
	FROM movie AS m
             INNER JOIN ratings AS r
                   ON m.id=r.movie_id
             INNER JOIN role_mapping AS rm
                   ON m.id = rm.movie_id
             INNER JOIN names AS n
		   ON rm.name_id = n.id
             INNER JOIN GENRE AS g
                  ON g.movie_id = m.id
	WHERE lower(category) = 'actress'
              AND avg_rating>8
              AND lower(genre) = "drama"
	GROUP BY name )
SELECT *,
	   Rank() OVER(ORDER BY movie_count DESC) AS actress_rank
FROM actress_summary LIMIT 3;

-- Parvathy Thiruvothu, Susan Brown and Amanda Lawrence are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre.






/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:
WITH next_date_published_detail
     AS( SELECT d.name_id, name, d.movie_id, duration, r.avg_rating, total_votes, m.date_published,
                Lead(date_published,1) OVER(partition BY d.name_id ORDER BY date_published,movie_id ) AS next_date_published
          FROM director_mapping  AS d
               INNER JOIN names  AS n
                     ON n.id = d.name_id
               INNER JOIN movie AS m
                     ON m.id = d.movie_id
               INNER JOIN ratings AS r
                     ON r.movie_id = m.id ),
top_director_summary AS
( SELECT *,
         Datediff(next_date_published, date_published) AS inter_movie_duration
  FROM   next_date_published_detail )
SELECT   name_id AS director_id,
         name AS director_name,
         Count(movie_id) AS number_of_movies,
         Round(Avg(inter_movie_duration),2) AS avg_inter_movie_days,
         Round(Avg(avg_rating),2) AS avg_rating,
         Sum(total_votes) AS total_votes,
         Min(avg_rating) AS min_rating,
         Max(avg_rating) AS max_rating,
         Sum(duration) AS total_duration
FROM top_director_summary
GROUP BY director_id
ORDER BY Count(movie_id) DESC limit 9;






