
###Tìm các diễn viên đóng vai Bartender
select	concat(first_name, ' ',last_name)	as 'Name',
		name				as 'Movie name',
		role
from roles r
	inner join actors a on r.actor_id = a.id
	inner join movies m on r.movie_id = m.id
where role like 'Bartender%';

### Tìm tên các role của từng phim
select name, group_concat(role separator ', ') as 'All role'
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
select	concat(first_name, ' ',last_name)	as 'Actors\'s name',
	group_concat(name separator '; ')	as 'Movies'
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
	concat(d.first_name, ' ',d.last_name)	as 'Directors\'s name',		
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
	group_concat(a.first_name, ' ',a.last_name separator ', ')	as 'Actors\'s name',
	count(a.id)							as 'Amount'
from roles r
	inner join movies m on m.id = r.movie_id
	inner join actors a on a.id = r.actor_id
group by m.id;


### Đạo diễn làm ra bộ phim có rank thấp thứ 2 được sản xuất sau năm 2000
select	concat(d.first_name, ' ',d.last_name)	as 'Directors\'s name',
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

select	concat(first_name, ' ',last_name)	as 'Actors\'s name',
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


    
    
