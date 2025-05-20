create database Pizza_Sales;

use pizza_sales;

/*Create Orders table*/
create table orders(
Order_ID int not null,
Order_Date date not null,
Order_Time time not null,
primary key(Order_ID));

/*Create Order Details table*/
create table Order_Details(
Order_Details_ID int not null,
Order_ID int not null,
Pizza_ID text not null,
quantity int not null,
primary key(Order_Details_ID));