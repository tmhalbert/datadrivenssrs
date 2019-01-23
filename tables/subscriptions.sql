create table subscriptions (
  subscriptionid uniqueidentifier primary key,
  scheduleid uniqueidentifier not null,
  contactid uniqueidentifier not null,
  reportid uniqueidentifier not null,
  formatid uniqueidentifier not null,
  reportcode nvarchar(260) not null,
  active bit not null default 1,
  constraint uq_subscription
    unique nonclustered (contactid, reportcode, formatid, scheduleid, reportid),
  constraint fk_subscriptions_scheduleid
    foreign key (scheduleid)
      references schedules (scheduleid),
  constraint fk_subscriptions_contactid
    foreign key (contactid)
      references contacts (contactid),
  constraint fk_subscriptions_reportid
    foreign key (reportid)
      references reports (reportid),
  constraint fk_subscriptions_formatid
    foreign key (formatid)
      references formats (formatid),
  constraint fk_subscriptions_reportcode
    foreign key (reportcode)
      references customers (customercode)  
)