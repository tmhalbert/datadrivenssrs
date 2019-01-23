# datadrivenssrs

A basic SQL library meant to assist others in getting the dynamic report generation functionality of Microsoft SQL Server Reporting Services' Data Driven Subscriptions and Email Delivery without having to updrage to an Enterprise license.

The code here does not provide a functioning program, but rather is meant to assist you in implementing your own solution specific to your needs. 

The use case that led me here is very unique and proprietary. However, I wanted to share the general implementation with anyone else looking for a little more flexibility out of the current SSRS subscription options provided by Microsoft SQL Server Standard Edition. 

Basic background on the project.. 

1. There's a new SQL server in AWS that's an aspiring dimensional model db representing the companies primary business apllication.
2. This server is also home to the companies newly upgraded SSRS server. Moving from 2008 R2 Enterprise to 2017 Standard.
3. For years the company has heavily relied on the data driven subscription functionality of SSRS, and it wasn't realized until it was time to implement a delivery queue that the new license didn't include this function. 
4. Upgrading to Enterprise for this single feature is extremely expensive!

So I've been tasked in finding a hacky way to keep moving forward...

Other things to consider..

1. I've stripped out all business logic and effectivly broke it to share it
2. There are a few things here and there that might seem out of place. it's future or feature. 
3. Be critical and sharing if there's an easier way :)


## Usage

First, I created a seperate DB to keep from messing up the SSRS DB:

```
use master
go

create database distribution
```


Next, I created some tables (use the sql files in /tables/*.sql):

`contacts.sql`, `customers.sql`, `formats.sql`, `reports.sql`, `schedules.sql`, `subscriptions.sql`

NOTES:

1. We faced an interesting customer parent/child hierarchy where each level is a defferent customer from a service perspective, the same account throughout from a billing perspective, and there are process/logic requirements that cross trees via codes & tags, most of which has been stripped out.
2. As a result, you'll notice contacts for reports are not associated with customers. This was intentional but not likely your use case.
3. Customers are still in this example to demonstrate the `cobranding` piece. Our external reports can be cobranded with the top level customer's logo. By setting a report parameter, the report will load the appropriate logofile. Pretty cool stuff :)

### schedules.sql

In order for this use case to work, you need to pre-define some Shared Schedules in SSRS. These then need to be synced to the distribution database. I've created 4:

1. Hourly
2. Daily
3. Weekly
4. Monthly

### reports.sql

The distribution database also needs to know a little bit about your SSRS Reports. Mainly the ID and Name (our front end process for interacting with all of this needs the Parameters).

### formats.sql

This is me overthinking things probably. We like to send reports as Excel or PDF. I want CSV to get utilized as well. This table just staticly defines those format types.

### customers.sql

This is where things really get specific to our use case..

Reports are run against different codes and/or tags that ultimately get you to a decision of whether or not to cobrand the report, as well as a few other feature parameters stripped out of this example. But this requires getting data into the distribution database from the existing application database. In our use case, this server is home to the normalized, modeled application data for report purposes .. so that was easy!

### contacts.sql

Like customers, contacts have options that set background parameters to dynamically alter reports (which has all been stripped from this example lol). Also, future self-service thought process, blah blah blah... oh, and these contacts aren't in our business application for .. reasons. So, this is also for our front end process to use.

### subscriptions.sql

The ultimate goal is to associate a `schedule` with a `report`, with a report `format`, with report `parameters`, with an `email` address. That happens here and gets assigned an ID.


Then, I created a bunch of Stored Procedures (use the sql files in /storedprocedures/*.sql):

`createcontacts.sql`, `createsubscriptions.sql`, `disablesubscriptions.sql`, `getcontacts.sql`, `getcustomers.sql`, `getformats.sql`, `getreports.sql`, `getschedules.sql`, `getsubscriptions.sql`, `updatecontacts.sql`, `upsertcustomers.sql`, `upsertreports.sql`, `upsertschedules.sql`

NOTE: All Create, Get, and Update/Disable procs are currently being executed by a front end web portal not part of this example. Upsert procs are being handled by SQL Agent Jobs once per day. 

### createsubscriptions.sql

This is the MAGIC!

Again, this example is very vanilla and stripped down. But, this is where the SSRS server is told about the new subscription and takes over everything from there. 

Building the ExtensionSettings XML string defines the email options like emailto, replyto, subject, attachment, etc. This will need to be advanced for more than just Email deliveries. 

Building the Parametes XML string sets all of your report parameters. This should be built dynamically depending on the parameters available/needed for the reportid chosen for the subscription.

Once you populate the variables in this proc, you can call the CreateSubscription proc in the SSRS reporting DB, _and then_ associate the SSRS SQL Agent Job that fires off the subscription using the ReportSchedule table, and finally save a copy of all that in the distribution DB. 


## Contributing

### Thank You

I hope this helps others looking for a little bit of that data driven subscription fix :)

Pull requests are welcome.