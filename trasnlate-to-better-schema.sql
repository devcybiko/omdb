--
-- this script reads the omdb tables and creates a simplified, potentially less normalized schema
-- the biggest improvement is 
-- improvements 
-- - elimiation of ambiguous field names "root_id" and "parent_id"
-- - all tables have an 'id' field
-- - tables have more logical names (noun ending in 's')
-- - movies and tv shows in the same "shows" table (with 'kind' column set to 'tv' or 'movie')
-- - elimination of 'helper' tables
-- - foreign keys are named for the foreign table (eg: show_id, person_id, etc...)
-- - denormalized several tables
-- - removed support for multiple languages - defaulting to English

-- franchises - a table of all the movie/tv franchises (star wars, star trek, etc...) (no references)
-- shows - a table of all shows (both movies and tv shows) (refers to franchises)
-- seasons - a table of all seasons of tv shows (refers to shows and episodes)
-- episodes - a table of all episodes of tv shows (refers to shows and seasons)
-- show_attrs - a listing of attributes and values (eg: GENRE, KEYWORD, can be multiple values per attr) (refers to shows)
-- roles - cast and crew of each show (not episodes) (refers to shows and persons)
-- persons - real people who perform the roles (no references)
-- franchises -> shows -> episodes
--               shows -> seasons -> episodes
--               shows -> show_attrs
--               shows -> roles <- persons

-- -----------------------

-- 
-- disable safe mode so you can update without specifying a key field
--
SET SQL_SAFE_UPDATES=0;

-- ----------------------------

--
-- create the francises table
--
drop table if exists franchises;
CREATE TABLE `franchises` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(2048) NOT NULL,
  `date` date NOT NULL,
  `abstract` varchar(2048) default null,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=128946 DEFAULT CHARSET=latin1;

INSERT INTO `franchises`
(`id`,
`name`,
`date`)
select id, name, date from all_movieseries;

update franchises 
join movie_abstracts_en
on movie_abstracts_en.movie_id = franchises.id
set franchises.abstract = movie_abstracts_en.abstract;

select * from franchises;

-- --------------------------------------

drop table if exists shows;
CREATE TABLE `shows` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(2048) NOT NULL,
  `franchise_id` int(11) DEFAULT NULL,
  `date` date NOT NULL,
  `kind` varchar(16) not null,
  `abstract` varchar(2048) default NULL,
  season int(11) default null,
  season_id int(11) default null,
  episode_number int(11) default null,
  show_id int(11) default null,
  last_update date default null,
  runtime int(11) default null,
  budget int(11) default null,
  revenue int(11) default null, 
  homepage varchar(2048) default null,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=129070 DEFAULT CHARSET=latin1;


--
-- get all the movies
--
INSERT INTO `shows`
(`id`,
`name`,
`franchise_id`,
`date`,
`kind`)
select id, name, parent_id as franchise_id, date, 'movie' as kind from all_movies;

--
-- get all the tv shows
--
INSERT INTO `shows`
(`id`,
`name`,
`franchise_id`,
`date`,
`kind`)
select id, name, parent_id as franchise_id, date, 'tv' as kind from all_series;

--
-- get all the tv episodes
--
INSERT INTO `shows`
(`id`,
`name`,
`season`,
`episode_number`,
`season_id`,
`date`,
`show_id`,
`kind`)
select id, name, '0' as season, '0' as number, parent_id as season_id, date, series_id as show_id, 'episode'
from all_episodes;

--
-- get all the abstracts (descriptions)
--
update shows 
join movie_abstracts_en
on movie_abstracts_en.movie_id = shows.id
set shows.abstract = movie_abstracts_en.abstract;

--
-- add in all the last updates dates
--
update shows
join movie_content_updates a
on shows.id = a.movie_id
set 
shows.last_update = a.last_update;

--
-- add in the details
-- 
update shows
join movie_details c
on shows.id = c.movie_id
set 
shows.budget = c.runtime,
shows.budget = c.budget, 
shows.revenue = c.revenue,
shows.homepage = c.homepage
;



-- ----------------------------------------------

drop table if exists seasons;
CREATE TABLE `seasons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(2048) NOT NULL,
  `show_id` int(11) DEFAULT NULL,
  `date` varchar(2048) NOT NULL,
  `number` int(11) default null,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=129031 DEFAULT CHARSET=latin1;

INSERT INTO seasons
(id, name, show_id, date, number)
select id, name, parent_id as show_id, date, 0 as number from all_seasons;

SET SQL_SAFE_UPDATES=0;

--
-- the following attempts to clean up some of the season names, normalizing them to integers 1,2,3...
-- not all seasons are corrected
-- for example, doctor who has 26+ seasons
-- seasons not corrected by these queries are set to '0'
--

-- select distinct(name) from seasons
update seasons set number = 1
where name like '1.%'
or name like '%Season 01 %'
or name like '%Season 01%'
or name like '%01 %'
or name like '1 %'
or name like '% 1 %'
or name like '% 1'
or name = '1'
or name like '% one%';

-- select distinct(name) from seasons
update seasons set number = 2
where name like '2.%'
or name like '2 %'
or name like '% 2'
or name like '% 2 %'
or name = '2'
or name like '% two%';

-- select distinct(name) from seasons
update seasons set number = 3
where name like '3.%'
or name like '3 %'
or name like '% 3'
or name like '% 3 %'
or name = '3'
or name like '% three%';

-- select distinct(name) from seasons
update seasons set number = 4
where name like '4.%'
or name like '% 4'
or name like '4 %'
or name like '% 4 %'
or name = '4'
or name like '% four%'
and name not like '% fourth%';

-- select distinct(name) from seasons
update seasons set number = 5
where name like '5.%'
or name like '% 5%'
or name like '% 05%'
or name = '5'
or name like '% five%';

-- select distinct(name) from seasons
update seasons set number = 6
where name like '5.%'
or name like '% 6%'
or name like '% 06%'
or name = '6'
or name like '% six%'
and name not like '% sixth%';

-- select distinct(name) from seasons
update seasons set number = 7
where name like '7.%'
or name like '% 7%'
or name like '% 07%'
or name = '7'
or name like '% seven%'
and name not like '% seventh%';

-- select distinct(name) from seasons
update seasons set number = 8
where name like '8.%'
or name like '% 8%'
or name like '% 08%'
or name = '8'
or name like '% eight%'
and name not like '% eighth%';

-- select distinct(name) from seasons
update seasons set number = 9
where name like '9.%'
or name like '% 9%'
or name like '% 09%'
or name = '9'
or name like '% nine%'
and name not like '% nineth%';

-- select distinct(name) from seasons
update seasons set number = 10
where name like '10.%'
or name like '% 10%'
or name = '10'
or name like '% ten%'
and name not like '% tenth%';

-- select distinct(name) from seasons
update seasons set number = 11
where name like '11.%'
or name like '% 11%'
or name = '11'
or name like '% eleven%'
and name not like '% eleventh%';

-- select distinct(name) from seasons
update seasons set number = 12
where name like '12.%'
or name like '% 12%'
or name = '12'
or name like '% twelve%'
and name not like '% twelveth%';

-- select distinct(name) from seasons
update seasons set number = 13
where name like '13.%'
or name like '% 13%'
or name = '13'
or name like '% thirteen%'
and name not like '% thirteenth%';

-- select distinct(name) from seasons
update seasons set number = 14
where name like '14.%'
or name like '% 14%'
or name = '14'
or name like '% fourteen%'
and name not like '% fourteenth%';

-- select distinct(name) from seasons
update seasons set number = 15
where name like '15.%'
or name like '% 15%'
or name = '15'
or name like '% fifteen%'
and name not like '% fifteenth%';

-- select distinct(name) from seasons
update seasons set number = 16
where name like '16.%'
or name like '% 16%'
or name = '16'
or name like '% sixteen%';

-- select distinct(name) from seasons
update seasons set number = 17
where name like '17.%'
or name like '% 17%'
or name = '17';

-- select distinct(name) from seasons
update seasons set number = 18
where name like '18.%'
or name like '% 18%'
or name = '18';

-- select distinct(name) from seasons
update seasons set number = 19
where name not like '% 19%-%'
and (name like '19.%' or name like '% 19%' or name = '19');

-- select distinct(name) from seasons
update seasons set number = 20
where name not like '% 20%/%'
and (name like '20.%' or name like '% 20%' or name = '20');

-- select distinct(name) from seasons
update seasons set number = 21
where name like '21.%' or name like '% 21%' or name = '21';

update shows set season = (select number from seasons where shows.season_id = seasons.id);

-- ------------------------

drop table if exists show_attrs;
CREATE TABLE `show_attrs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `show_id` INT NULL,
  `attr` VARCHAR(64) NULL,
  `val` VARCHAR(45) NULL,
  PRIMARY KEY (`id`));

insert into show_attrs (show_id, attr, val)
select distinct shows.id, attr.name, val.name
from shows, movie_categories, all_categories, category_names val, category_names attr
where 1=1
and movie_categories.movie_id = shows.id
and all_categories.id = movie_categories.category_id
and val.category_id = all_categories.parent_id
and attr.category_id = all_categories.root_id
and val.language_iso_639_1 = 'en'
and attr.language_iso_639_1 = 'en'
and attr.category_id <> val.category_id
order by shows.name, movie_categories.category_id
;

insert into show_attrs (show_id, attr, val)
select distinct shows.id, attr.name, val.name
from shows, movie_keywords, all_categories, category_names val, category_names attr
where 1=1
and movie_keywords.movie_id = shows.id
and all_categories.id = movie_keywords.category_id
and val.category_id = all_categories.parent_id
and attr.category_id = all_categories.root_id
and val.language_iso_639_1 = 'en'
and attr.language_iso_639_1 = 'en'
and attr.category_id <> val.category_id
order by shows.name, movie_keywords.category_id
;

-- -----------------------

drop table if exists roles;
CREATE TABLE `roles` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `show_id` INT NULL,
  `person_id` INT NULL,
  `billing` INT NULL,
  `role` VARCHAR(64) NULL,
  `name` VARCHAR(128) NULL,
  PRIMARY KEY (`id`));

insert into roles
(show_id, billing, person_id, role, name)
select distinct movie_id show_id, convert(position, signed) billing, person_id, j.name role, c.role name
from all_casts c, all_people p, job_names j
where 1=1
-- and c.movie_id = 11
and c.person_id = p.id
and j.job_id = c.job_id
and j.language_iso_639_1 = 'en'
order by show_id, billing, person_id, j.job_id
;

-- ------------------------

drop table if exists persons;
CREATE TABLE `persons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(2048) NOT NULL,
  `birth` date DEFAULT NULL,
  `death` date default NULL,
  `gender` varchar(16) default null,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=129070 DEFAULT CHARSET=latin1;

insert into persons
(id, name, birth, death, gender)
select id, name, convert(birthday, date) birth, convert(deathday, date) death, if(gender=0, 'male', 'female') gender
from all_people
where 1=1
;


-- -----------------

/**
 ** some sample queries

-- find every role william shatner has played
select franchises.name, shows.name, shows.kind, roles.name, persons.name
from shows, roles, persons, franchises
where 1=1
and persons.name like 'william shatner'
and roles.show_id = shows.id
and (franchises.id = shows.franchise_id or shows.franchise_id is null)
and roles.person_id = persons.id
and role = 'Actor'
order by franchises.name, shows.name, roles.billing;

-- find all episodes of franchiased series (like star trek)
select * from shows, episodes 
where shows.id = episodes.show_id and franchise_id is not null 
order by franchise_id, shows.id, episodes.season;

-- find all attr/value pairs for star wars (show_id=11)
select shows.name, attr, val
from shows, show_attrs
where 1=1
and shows.id = 11
and show_attrs.show_id = shows.id
;


**/