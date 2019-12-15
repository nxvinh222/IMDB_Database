
###Tìm các diễn viên đóng vai Bartender
select	concat(first_name, ' ',last_name)	as 'Name',
	name					as 'Movie name',
	role
from roles r
	inner join actors a on r.actor_id = a.id
	inner join movies m on r.movie_id = m.id
where role like 'Bartender%';

### Tìm tên các role của từng phim
select	name,
	group_concat(role separator ', ') as 'All role'
from roles r
	inner join movies m on m.id = r.movie_id
group by name;

### Tìm số diễn viên nam và nữ của từng phim
select	name,
	sum(case when gender = 'M' then 1 else 0 end) as 'Male actors',
	sum(case when gender = 'F' then 1 else 0 end) as 'Female actors'
from roles r
	inner join movies m on m.id = r.movie_id
	inner join actors a on a.id = r.actor_id
group by name;

### Các diễn viên có 2 phim trở lên đạt điểm 8 hoặc cao hơn và danh sách những phim đó
select	concat(first_name, ' ',last_name)	as 'Actors',
	group_concat(name separator ', ')	as 'Movies'
from roles r
	inner join movies m on m.id = r.movie_id
	inner join actors a on a.id = r.actor_id
where m.rank >= 8
group by a.id
having count(name) >= 2
order by first_name;

### Tìm các phim nằm trong cả 2 thể loại là Action và Thriller

select	m.name
from roles r
	inner join movies m on m.id = r.movie_id
	inner join movies_genres mg on m.id = mg.movie_id
where mg.genre in ('Action', 'Thriller')
group by m.name
having count(distinct mg.genre) = 2; 

### Xếp hạng các đạo diễn dựa trên sô điểm cao nhất từng đạt được

select	*,
	dense_rank() over (order by t.max_rank desc) as 'Overall rank'
from 
(select	d.id,
	concat(d.first_name, ' ',d.last_name)	as 'Directors',		
        m.name,
        max(m.rank)				as 'max_rank'
from directors d
	inner join movies_directors md on d.id = md.director_id
    inner join movies m on m.id = md.movie_id
group by d.id) t;

### Các phim được sản xuất trước năm 2000 có rank lớn hơn rank trung bình
select	m.name,
	m.rank,
	m.year
from movies m
where	m.year < 2000
	and
	m.rank > (select avg(m.rank)from movies m);
    
### Tìm danh sách và đếm số lượng những diễn viên của từng phim 
select	m.name,
	group_concat(a.first_name, ' ',a.last_name separator ', ')	as 'Actors',
	count(a.id)							as 'Amount'
from roles r
	inner join movies m on m.id = r.movie_id
	inner join actors a on a.id = r.actor_id
group by m.id;


### Đạo diễn làm ra bộ phim có rank thấp thứ 2 được sản xuất sau năm 2000
select	concat(d.first_name, ' ',d.last_name)	as 'Directors',
	m.name,
	m.rank
from directors d
	inner join movies_directors md on d.id = md.director_id
	inner join movies m on m.id = md.movie_id
where m.rank IS NOT NULL
order by m.rank
limit 1
offset 1;

### Các diễn viên không đóng phim Comedy

select	concat(first_name, ' ',last_name)	as 'Actors',
	group_concat(distinct genre)			as 'Genres participate in'
from roles r
	inner join movies m on m.id = r.movie_id
	inner join actors a on a.id = r.actor_id
	inner join movies_genres mg on m.id = mg.movie_id
where m.id not in	(select m_0.id
			 	from movies m_0
					inner join movies_genres mg_0 on m_0.id = mg_0.movie_id
			where genre = 'Comedy'
			)
group by a.id;


## danh sách những người thực hiện phim titanic
    select concat(d.first_name," ",d.last_name) as made_by
    from directors d
        inner join movies_directors md on d.id = md.director_id
        inner join movies m on md.movie_id = m.id
    where m.name = "Titanic"
union
    select concat(a.first_name," ",a.last_name)
    from actors a
        inner join roles r on a.id = r.actor_id
    where r.movie_id = (select id
    from movies
    where name = "Titanic");

## danh sách các cặp đôi nam-nữ đóng cùng nhau 2 lần trở lên
select z.couples, count(z.movie_id) as count
from
    (select concat(t1.name, " & ", t2.name) as couples, t1.movie_id
    from
        (select a1.id, concat(a1.first_name," ",a1.last_name) as name, r1.movie_id
        from actors a1
            inner join roles r1 on a1.id = r1.actor_id
        where a1.gender = "F") t1
        inner join
        (select a2.id, concat(a2.first_name," ",a2.last_name) as name, r2.movie_id
        from actors a2
            inner join roles r2 on a2.id = r2.actor_id
        where a2.gender = "M") t2
        on t1.movie_id = t2.movie_id) z
group by z.couples
having count > 1;


## danh sách các nữ diễn viên đóng phim kinh dị và các phim kinh dị họ góp mặt
select concat(a.first_name," ",a.last_name) as actress, group_concat(m.name) as movie
from actors a
    inner join roles r on a.id = r.actor_id
    inner join movies m on m.id = r.movie_id
    inner join movies_genres mg on m.id = mg.movie_id
where mg.genre = "horror" and a.gender = "F"
group by actress;

## tìm phim có diễn viên nam tên bắt đầu bằng chữ cái “A” mà có đóng thể loại phim hành động
select m.name, group_concat(last_name)
from movies m
    inner join roles r on r.movie_id = m.id
    inner join actors a on a.id = r.actor_id
where a.last_name like 'A%'
    and a.gender = "M"
    and exists (select *
    from actors a
        inner join roles r on a.id = r.actor_id
        inner join movies_genres mg on r.movie_id = mg.movie_id
    where mg.genre = "action")
group by m.name;

## danh sách các đạo diễn làm phim mà có diễn viên nam đóng vai bác sĩ(tiến sĩ)
select distinct concat(d.first_name," ",d.last_name) as name
from directors d
    inner join movies_directors md on d.id = md.director_id
where md.movie_id = any (select r.movie_id
from roles r
    inner join actors a on a.id = r.actor_id
where r.role like 'Dr.%' and a.gender = "M");

## danh sách các diễn viên quần chúng(không có tên vai diễn) và tên phim họ đóng không thuộc thể loại romance và sản xuất năm 2005
select concat(a.first_name," ",a.last_name) as name, r.role, m.name
from actors a
    inner join roles r on r.actor_id = a.id
    inner join movies m on m.id = r.movie_id
where char_length(r.role) = 0
    and m.id not in (select movie_id
    from movies_genres
    where genre = "romance")
    and m.year = 2005;

## danh sách tên các diễn viên đóng trong phim có rank cao thứ 3 thuộc thể loại action, comedy
select concat(a.first_name," ",a.last_name) as name, m.name as movie
from actors a
    inner join roles r on r.actor_id = a.id
    inner join movies m on m.id = r.movie_id
where r.movie_id = (select m.id
from movies m
    inner join movies_genres mg on mg.movie_id = m.id
where genre in ("action", "comedy")
    and m.rank is not null
order by m.rank desc
limit 1 offset 3);

## danh sách tên các bộ phim và thể loại của chúng mà có dưới 3 nữ diễn viên góp mặt
select m.name, group_concat(mg.genre) as genre
from movies m
    inner join movies_genres mg on m.id = mg.movie_id
where id in (select r.movie_id
from roles r
    inner join actors a on a.id = r.actor_id
where a.gender = "F"
group by r.movie_id
having count(a.id) <= 2)
group by m.name;

## các thể loại phim phổ biến nhất và số diễn viên tham gia thể loại này
select mg.genre, count(distinct mg.movie_id) as num_of_movie, t.num_of_actor
from movies_genres mg
    inner join (select mg.genre, count(r.actor_id) as num_of_actor
    from roles r
        inner join movies_genres mg on r.movie_id = mg.movie_id
    group by mg.genre) t on mg.genre = t.genre
group by mg.genre
having num_of_movie >= all(select count(movie_id)
from movies_genres
group by genre);

## danh sách các đạo diễn và đánh giá qua bộ phim tốt nhất của họ
select t.name, case 
when max_rank >= 9 then "Exellent"
when max_rank < 9 and max_rank >= 7 then "Good"
when max_rank < 7 and max_rank >= 6 then "Not Good"
when max_rank < 6 then "Bad"
else "Undefined"
end as Comment
from (select concat(d.first_name," ",d.last_name) as name, max(m.rank) as max_rank
    from directors d
        inner join movies_directors md on d.id = md.director_id
        inner join movies m on m.id = md.movie_id
    group by md.director_id) t;


    
