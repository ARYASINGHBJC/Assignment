-- Assignment 1
create table TekEmp(
	empid varchar(10),
    empName varchar(20),
    salary int,
    deptID varchar(20),
    managerId varchar(20)
);

create table TekDept(
	deptID varchar(20),
    deptName Varchar(20)
);

create table TekMng(
	managerId varchar(20),
    managerName varchar(20),
    deptId varchar(20)
);

create table TekPrj(
	prjId varchar(20),
    prjName Varchar(20),
    teamMemberId varchar(20)
);


insert into TekEmp values("E1","ABC",15000,"D1","M1");
insert into TekEmp values("E2","DEF",15000,"D1","M1");
insert into TekEmp values("E3","GHI",25000,"D1","M2");
insert into TekEmp values("E4","JKL",25000,"D2","M2");
insert into TekEmp values("E5","MNO",35000,"D2","M2");
insert into TekEmp values("E6","PQR",35000,"D3","M3");
insert into TekEmp values("E7","STU",35000,"D4","M3");
insert into TekEmp values("E8","VWX",45000,"D4","M3");
insert into TekEMP values("E9","YZA",45000,null,null);

insert into TekDept values 
	("D1","DEPARTMENT 1"),
	("D2","DEPARTMENT 2"),
    ("D3","DEPARTMENT 3"),
	("D4","DEPARTMENT 4"),
    ("D5","DEPARTMENT 5"),
	("D6","DEPARTMENT 6")
;


ALTER TABLE TekMng
modify COLUMN deptId varchar(20);

insert into TekMng values 
	("M1","MANAGER 1","D1"),
    ("M2","MANAGER 2","D1"),
    ("M2","MANAGER 2","D2"),
    ("M3","MANAGER 3","D3"),
    ("M3","MANAGER 2","D4")
;

insert into TekPrj values
	("P1","Project 1","E1"),
    ("P1","Project 1","E2"),
    ("P1","Project 1","E3"),
    
    ("P2","Project 2","E1"),
	("P2","Project 2","E4"),
    ("P2","Project 2","E5"),
    ("P2","Project 2","E6"),
    
    ("P3","Project 3","E2"),
    ("P3","Project 3","E7"),
    ("P3","Project 3","E8")
;

-- Q1 Diplay all records from all tables
select * from tekemp;
select * from tekmng;
select * from tekdept;
select * from tekprj;

-- Q2 Fetch the employee name and dept they belong to 
select empName,deptName from tekemp join tekdept on tekemp.deptID = tekdept.deptID;

-- Q3 Fetch all employee name and their respective departmen name 
select empName,deptName from tekemp left join tekdept on tekemp.deptID = tekdept.deptID;

-- Q4 fetch all departments name and employee name working in it 
select empName,deptName from tekemp right join tekdept on tekemp.deptID = tekdept.deptID;

-- Q5 fetch all department name and all employess name working in it ;
select empName,deptName from tekemp left join tekdept on tekemp.deptID = tekdept.deptID
union 
select empName,deptName from tekemp right join tekdept on tekemp.deptID = tekdept.deptID
;

-- Q6 
select * from tekemp join tekmng on tekemp.managerId = tekmng.managerId  join tekdept on tekdept.deptID = tekemp.deptID join tekprj on tekprj.teamMemberId = tekemp.empid order by empid;

-- Q7
select * from tekemp left join tekmng on tekemp.managerId = tekmng.managerId  left join tekdept on tekdept.deptID = tekemp.deptID left join tekprj on tekprj.teamMemberId = tekemp.empid order by empid;
