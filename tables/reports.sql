create table reports (
  reportid uniqueidentifier primary key,
  reportname nvarchar(260) not null unique,
  parameters nvarchar(max) not null
)