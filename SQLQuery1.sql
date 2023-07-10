drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

    /* 1	What is the total amount each customer spent on Zomato?*/
select a.userid, sum(b.price) as total_amt_spent from sales a INNER JOIN product b on a.product_id=b.product_id
group by userid

	/* 2	How many days has each customer visited Zomato?*/
select userid, count(distinct created_date) distinct_days from sales group by userid

	/* 3    What was the first product purchased by each customer? */
select * from
(select * , rank() over (partition by userid order by created_date) rnk from sales) a where rnk=1

	/*4		What is the most purchased item on the menu and how many times was it purchased by all customers?*/
	/*select product_id, count(product_id) from sales group by product_id order by count(product_id) desc*/
	/*select product_id, count(product_id) from sales group by product_id order by count(product_id) desc*/
select top 1 product_id from sales group by product_id order by count(product_id) desc


	/*5		Now, if we want to know how many times this particular product was purchased by each of the customers?*/
select * from sales 
where product_id = (select top 1 product_id from sales group by product_id order by count(product_id) desc)

	/*6		How many times has a user purchased this topmost product? */
select userid, count(product_id) cnt from sales
where product_id = (select top 1 product_id from sales group by product_id order by count(product_id) desc)
group by userid

	/*7		Which item was the most popular for each customer? */
select * from
(select * , rank() over(partition by userid order by cnt desc) rnk from
(select userid, product_id, count(product_id) cnt from sales group by userid,product_id)  a)b
where rnk=1


	/*8		Which item was first purchased by the customer after they became a gold member? */
select d.* from
(select c.* , rank() over(partition by userid order by created_date) rnk from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date) c)d where rnk=1;

	/*9		Which item was purchased just before the customer became a gold member? */
select d.* from
(select c.* , rank() over(partition by userid order by created_date desc) rnk from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid=b.userid and created_date<=gold_signup_date) c)d where rnk=1

	/*10	What is the total order and amount spent for each user before they became a gold member? */
select userid, count(created_date) total_no_of_orders, sum(price) total_amt_spent from
(select c.* , d.price from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid=b.userid and created_date<=gold_signup_date) c inner join product d on c.product_id=d.product_id)e
group by userid

	/*11	If buying each product generates points for ex 5Rs=2 Zomato Points and each product has different purchasing points 
for eg for p1 5Rs=1 Zomato Point , for p2 10Rs=5 Zomato Point i. 2Rs=1 Zomato Point, and p3 5Rs=1 Zomato Point 
Calculate points collected by each customers and for which product most points have been given till now*/

select e.*, amt/points total_reward_points from
(select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(select c.userid, c.product_id, sum(price) amt from
(select a.* , b.price from sales a inner join product b on a.product_id=b.product_id)c group by userid,product_id)d)e





