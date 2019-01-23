create table customers (
  customerid uniqueidentifier primary key,
  customername nvarchar(260) not null unique,
  customercode nvarchar(260) not null unique,
  cobranding bit not null default 0,
  logofile nvarchar(max) null      
)