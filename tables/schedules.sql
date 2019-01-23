create table schedules (
  scheduleid uniqueidentifier primary key,
  schedulename nvarchar(260) unique,
  recurrence int not null,
  lastruntime datetime
)