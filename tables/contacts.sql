create table contacts (
  contactid uniqueidentifier primary key default newid(),
  firstname nvarchar(260) null,
  lastname nvarchar(260) null,
  email nvarchar(260) unique not null
)