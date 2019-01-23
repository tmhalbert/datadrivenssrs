create table formats (
  formatid uniqueidentifier primary key,
  formatname nvarchar(260) not null unique
)

insert into formats (formatid, formatname)
select
  cast(newid() as uniqueidentifier) as formatid,
  'CSV (comma delimited)'           as formatname
union all
select
  cast(newid() as uniqueidentifier) as formatid,
  'Excel'                           as formatname
union all
select
  cast(newid() as uniqueidentifier) as formatid,
  'PDF'                             as formatname