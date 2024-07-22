use electoralbonddata;
Show Tables;
select * from bonddata;
select * from donordata;
select * from bankdata;
select * from receiverdata;

-- 1. Find out how much donors spent on bonds
with  donor_spent as (select d.Purchaser,b.Denomination from donordata d join bonddata b
					on d.Unique_key=b.Unique_key)
select purchaser,sum(denomination) from donor_spent group by 1 order by 2 desc;


-- 2Find out total fund politicians got
with funds_politicians as(select r.PartyName,sum(b.Denomination) as Total_funds from receiverdata r inner join bonddata b
on r.Unique_key=b.Unique_key
group by 1
order by 2 desc
)
select * from funds_politicians;

-- 3.Find out the total amount of unaccounted money received by parties
with unaccounted_money as (
    SELECT PartyName, SUM(b.Denomination) AS TotalUnaccountedAmount 
    FROM receiverdata r left join bonddata b
    on r.Unique_key = b.Unique_key
    WHERE AccountNUm is null
    GROUP BY PartyName
)
SELECT PartyName, TotalUnaccountedAmount 
FROM unaccounted_money;


-- Find year wise how much money is spend on bonds
with year_spend as (select year(d.PurchaseDate),sum(b.Denomination)  from donordata d inner join 
					bonddata b on d.Unique_key=b.Unique_key
                    group by 1
                    order by 1, 2)
select *  from year_spend;
-- In which month most amount is spent on bonds
with max_spend_month as (select month(d.PurchaseDate) as Month , sum(b.Denomination) as max__amount from donordata d inner join bonddata b
						 on d.Unique_key=b.Unique_key
                         group by 1
                         order by 2 desc
                         limit 1)
select * from max_spend_month;

-- Find out which company bought the highest number of bonds
with highest_company as (select d.Purchaser,sum(b.Denomination) from donordata d inner join bonddata b
							on d.Unique_key=b.Unique_key
                            group by 1
                            order by 2 desc
                            limit 1)
select * from highest_company;

-- Find out which company spent the most on electoral bonds.
with company_electoral as (select d.Purchaser from donordata d inner join bonddata b
							on d.Unique_key=b.Unique_key
                            group by 1
                            order by sum(b.Denomination) desc
                            limit 1)
select * from company_electoral;

-- List companies which paid the least to political parties.
WITH Payments AS (
    SELECT d.Purchaser, sum(b.Denomination) AS total_amount_paid from donordata d inner join bonddata b
    on d.Unique_key=b.Unique_key
    group by 1 
    order by 2)
select * from Payments
where total_amount_paid=(SELECT MIN(total_amount_paid) FROM bonddata);

-- Which political party received the highest cash?
with highest_political as ( select r.PartyName,sum(b.Denomination) from receiverdata r inner join bonddata b
							on r.Unique_key=b.Unique_key
                            group by 1
                            order by 2 desc
                            limit 1)
select * from highest_political;
-- 10. Which political party received the highest number of electoral bonds?
with highest_bonds as ( select r.PartyName,count(b.Denomination) from receiverdata r inner join bonddata b
							on r.Unique_key=b.Unique_key
                            group by 1
                            order by 2 desc
                            limit 1)
select * from highest_bonds;

-- Which political party received the least cash?
with highest_political as ( select r.PartyName,sum(b.Denomination) from receiverdata r inner join bonddata b
							on r.Unique_key=b.Unique_key
                            group by 1
                            order by 2 
                            limit 1)
select * from highest_political;

-- Which political party received the least number of electoral bonds?
with highest_bonds as ( select r.PartyName,count(b.Denomination) from receiverdata r inner join bonddata b
							on r.Unique_key=b.Unique_key
                            group by 1
                            order by 2 
                            limit 1)
select * from highest_bonds;

-- Find the 2nd highest donor in terms of amount he paid?
with highest_company as (select d.Purchaser,sum(b.Denomination) from donordata d inner join bonddata b
							on d.Unique_key=b.Unique_key
                            group by 1
                            order by 2 desc
                            limit 1 offset 1)
select * from highest_company;

-- Find the party which received the second highest donations?
with highest_political as ( select r.PartyName,sum(b.Denomination) from receiverdata r inner join bonddata b
							on r.Unique_key=b.Unique_key
                            group by 1
                            order by 2 desc
                            limit 1 offset 1)
select * from highest_political;

-- Find the party which received the second highest number of bonds?
with highest_bonds as ( select r.PartyName,count(b.Denomination) from receiverdata r inner join bonddata b
							on r.Unique_key=b.Unique_key
                            group by 1
                            order by 2 desc
                            limit 1 offset 1)
select * from highest_bonds;

-- In which city were the most number of bonds purchased? 
with city_bond as ( select b.City, count(b1.Denomination) from bankdata b inner join donordata d on b.branchCodeNo=d.PayBranchCode
					join bonddata b1 on d.Unique_key=b1.Unique_key
                    group by 1 
                    order by 2 desc
                    limit 1)
select * from city_bond;

-- 17. In which city was the highest amount spent on electoral bonds?
with city_bond as ( select b.City, sum(b1.Denomination) from bankdata b inner join donordata d on b.branchCodeNo=d.PayBranchCode
					join bonddata b1 on d.Unique_key=b1.Unique_key
                    group by 1 
                    order by 2 desc
                    limit 1)
select * from city_bond;

-- 18. In which city were the least number of bonds purchased?
with city_bond as ( select b.City, count(b1.Denomination) from bankdata b inner join donordata d on b.branchCodeNo=d.PayBranchCode
					join bonddata b1 on d.Unique_key=b1.Unique_key
                    group by 1 
                    order by 2 
                    limit 1)
select * from city_bond;

-- 19. In which city were the most number of bonds enchased?
with city_enchased as ( select b.City,count(r.DateEncashment) as bonds_into_cash from bankdata b inner join receiverdata r
						on b.branchCodeNo=r.PayBranchCode
                        group by 1
                        order by 2 desc
                        limit 1
                        )
select * from city_enchased;

-- In which city were the least number of bonds enchased?
with city_enchased as ( select b.City,count(r.DateEncashment) as bonds_into_cash from bankdata b inner join receiverdata r
						on b.branchCodeNo=r.PayBranchCode
                        group by 1
                        order by 2 
                        limit 1
                        )
select * from city_enchased;

-- List the branches where no electoral bonds were bought; if none, mention it as null.
with no_bonds as ( select b.Address from bankdata b left join donordata d
				   on b.branchCodeNo=d.PayBranchCode
                   where d.PayBranchCode is null)
select * from no_bonds;

-- Break down how much money is spent on electoral bonds for each year.
with money_spent_yearly as (select year(d.PurchaseDate) as year,sum(b.Denomination) as Amount_spent_yearly from donordata d inner join bonddata b
							on d.Unique_key=b.Unique_key
                            group by 1
                            order by 1, 2)
select * from money_spent_yearly;

/* Break down how much money is spent on electoral bonds for each year and provide the year and the amount. Provide values
for the highest and least year and amount */
with money_spent_yearly as (select year(d.PurchaseDate) as year,sum(b.Denomination) as Amount_spent_yearly from donordata d inner join bonddata b
							on d.Unique_key=b.Unique_key
                            group by 1
                            order by 2),
highest_year as (select year,Amount_spent_yearly from money_spent_yearly
				 group by 1
                 order by 2 desc
                 limit 1),
least_year as (select year,Amount_spent_yearly from money_spent_yearly
				 group by 1
                 order by 2 asc
)
SELECT * FROM money_spent_yearly
UNION ALL
SELECT 'Highest Amount' AS year, Amount_spent_yearly
FROM highest_year
UNION ALL
SELECT 'Least Amount' AS year, Amount_spent_yearly
FROM least_year;

-- 24. Find out how many donors bought the bonds but did not donate to any political party?
with not_donate as ( select distinct d.Purchaser from donordata d left join receiverdata r
					on d.Unique_key=r.Unique_key
                    where r.Unique_key is null)
select count(*) from not_donate;

-- 25. Find out the money that could have gone to the PM Office, assuming the above question assumption (Domain Knowledge)
WITH not_donate AS (
    SELECT DISTINCT d.Purchaser, b.Denomination
    FROM donordata d
    LEFT JOIN receiverdata r ON d.Unique_key = r.Unique_key
    LEFT JOIN bonddata b ON d.Unique_key = b.Unique_key
    WHERE r.Unique_key IS NULL
)
SELECT SUM(not_donate.Denomination) as Total_amount
FROM not_donate;

--  26. Find out how many bonds don't have donors associated with them.
WITH bonds_without_donors AS (
    SELECT b.Unique_key
    FROM bonddata b
    LEFT JOIN donordata d ON b.Unique_key = d.Unique_key
    WHERE d.Unique_key IS NULL
)
SELECT COUNT(*)
FROM bonds_without_donors;
select * from donordata;
/* 27. Pay Teller is the employee ID who either created the bond or redeemed it. So find the employee ID who issued the highest
number of bonds.*/
with highest_bonds as ( select d.payTeller as Employee_ID,count(b.Denomination) as No_of_bonds from donordata d inner join bonddata b
						on d.Unique_key=b.Unique_key
                        group by 1
                        order by 2 desc
                        limit 1
                        )
select * from highest_bonds;

-- 28. Find the employee ID who issued the least number of bonds.
with lowest_bonds as ( select d.payTeller as Employee_ID,count(b.Denomination) as No_of_bonds from donordata d inner join bonddata b
						on d.Unique_key=b.Unique_key
                        group by 1
                        order by 2 
                        limit 1
                        )
select * from lowest_bonds;
select * from receiverdata;

-- 29. Find the employee ID who assisted in redeeming or enchasing bonds the most.
with emp_enchasing as (select PayTeller as Employee_ID,count(DateEncashment) as Enchasing_count from receiverdata
						group by 1
                        order by 2 desc
                        )
select * from emp_enchasing
limit 1;

-- 30. Find the employee ID who assisted in redeeming or enchasing bonds the least
with emp_enchasing as (select PayTeller as Employee_ID,count(DateEncashment) as Enchasing_count from receiverdata
						group by 1
                        order by 2 
                        )
select * from emp_enchasing
limit 1;

/******************************************************************************************************************/
-- 1. Tell me total how many bonds are created?
with bonds_credited as (select count(Denomination) as NO_OF_BONDS from bonddata) 
select * from bonds_credited;
select * from receiverdata;

-- 2. Find the count of Unique Denominations provided by SBI?
SELECT COUNT(DISTINCT Denomination) AS UniqueDenominationCount
FROM bonddata;

-- 3. List all the unique denominations that are available
select distinct Denomination from bonddata
order by 1 desc;

-- 4. Total money received by the bank for selling bonds
with total_money as ( select sum(b.Denomination) as received_meoney from bonddata b)
select * from total_money;

-- 5. Find the count of bonds for each denominations that are created.
select Denomination, count(*) as bond_count
from bonddata
group by Denomination;

-- 6. Find the count and Amount or Valuation of electoral bonds for each denominations
select Denomination,count(*),sum(Denomination) from bonddata
group by 1
order by 3 desc;

-- 7. Number of unique bank branches where we can buy electoral bond?
select distinct count(branchCodeNo) as Unique_Branches from bankdata;

-- 8. How many companies bought electoral bonds
select count(Purchaser) as NO_OF_Comapanies from donordata;

-- 9. How many companies made political donations
select distinct count(d.Purchaser) as NO_OF_political_donations from donordata d left join receiverdata r
on d.Unique_key=r.Unique_key
where r.Unique_key is not null
order by 1;

-- 10. How many number of parties received donations
select count(r.PartyName) as parties_received_donations from receiverdata r inner join donordata d 
on r.Unique_key=d.Unique_key;

-- 11. List all the political parties that received donations
select distinct r.partyName from receiverdata r inner join donordata d
on r.Unique_key=d.Unique_key
order by 1;

-- 12. What is the average amount that each political party received
select r.PartyName,avg(b.Denomination) as Average_Amount from receiverdata r inner join bonddata b
on r.Unique_key=b.Unique_key
group by 1
order by 2 desc;

-- 13. What is the average bond value produced by bank
select avg(Denomination) as Average_bond_value from bonddata;

-- 14.List the political parties which have enchased bonds in different cities
select distinct r.PartyName from receiverdata r inner join bankdata b
on r.PayBranchCode=b.branchCodeNo
join donordata d on d.Unique_key=r.Unique_key;

/* 15.List the political parties which have enchased bonds in different cities and list the cities in which the bonds have enchased
as well? */
select distinct r.PartyName,b.CITY from receiverdata r inner join bankdata b
on r.PayBranchCode=b.branchCodeNo
join donordata d on d.Unique_key=r.Unique_key;


