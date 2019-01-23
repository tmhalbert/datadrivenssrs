use distribution
go

set ansi_nulls on
go
set quoted_identifier on
go

-- =====================================================
-- Author:		  Tim Halbert (tim@halberthub.com)
-- Create date: 01/23/2019
-- Description:	Creates a new distribution subscription
-- =====================================================

alter procedure sp_create_distribution_subscriptions
	@json nvarchar(max)
as
begin
	set nocount on


	-- =====================================================
	--                     VARIABLES
	-- =====================================================

  -- ssrs CreateSubscription variables
	declare
		@id uniqueidentifier = cast(newid() as uniqueidentifier),
		@Locale nvarchar (128) = 'en-US',
		@Report_Name nvarchar (425) = NULL,
		@ReportZone int = 0,
		@OwnerSid varbinary (85) = NULL, -- 0x0105000000000005150000003C165F6F49BDF3BBDDF99ABD560A0000 (sid from reporting.Users),
		@OwnerName nvarchar(260) = NULL, -- 'DOMAIN/username',
		@OwnerAuthType int = 1,
		@DeliveryExtension nvarchar (260) = 'Report Server Email',
		@InactiveFlags int = 0,
		@ExtensionSettings nvarchar(max) = NULL,
		@ModifiedBySid varbinary (85) = NULL, -- 0x0105000000000005150000003C165F6F49BDF3BBDDF99ABD560A0000 (sid from reporting.Users),
		@ModifiedByName nvarchar(260) = NULL, -- 'DOMAIN/username',
		@ModifiedByAuthType int = 1,
		@ModifiedDate datetime = getdate(),
		@Description nvarchar(512) = NULL,
		@LastStatus nvarchar(260) = 'New Subscription',
		@EventType nvarchar(260) = 'TimedSubscription',
		@MatchData nvarchar(max) = json_value(@json, '$.scheduleid'),
		@Parameters nvarchar(max) = NULL,
		@DataSettings nvarchar(max) = NULL,
		@Version int = 3


	-- =====================================================
	--                       WORK
	-- =====================================================

	-- get additional report info
	declare @reportpath nvarchar(260) = (select [Path] from [reporting].[dbo].[Catalog] where [ItemID] = json_value(@json, '$.reportid'))
	set @Report_Name = @reportpath

	-- set InactiveFlags in reporting db
	if json_value(@json, '$.active') = 0 begin
		set @InactiveFlags = 128
	end

	-- set ExtensionSettings variable for reporting db
	declare @emailto nvarchar(260),
		-- @emailcc nvarchar(260),
		-- @replyto nvarchar(260),
		@formatname nvarchar(260),
		@subject nvarchar(260) = '@ReportName was executed at @ExecutionTime'--,
		-- @comment nvarchar(max)

	set @emailto = (select email from contacts where contactid = json_value(@json, '$.contactid'))
	set @formatname = (select formatname from formats where formatid = json_value(@json, '$.formatid'))

	set @ExtensionSettings = (select concat('<ParameterValues><ParameterValue><Name>TO</Name><Value>', @emailto,
		'</Value></ParameterValue><ParameterValue><Name>IncludeReport</Name><Value>True</Value></ParameterValue><ParameterValue><Name>RenderFormat</Name><Value>', @formatname,
		'</Value></ParameterValue><ParameterValue><Name>Subject</Name><Value>', @subject,
		'</Value></ParameterValue><ParameterValue><Name>IncludeLink</Name><Value>False</Value></ParameterValue><ParameterValue><Name>Priority</Name><Value>NORMAL</Value></ParameterValue></ParameterValues>'))

	-- description
	set @Description = @id

	-- parameters - report specific for now but can br read and populated from parameters column in distribution db
	declare @reportcode nvarchar(260) = json_value(@json, '$.reportcode'),
		@startdate datetime,
		@enddate datetime,
		@cobrand bit = 0

	declare @recurrence int = (select recurrence from schedules where scheduleid = json_value(@json, '$.scheduleid'))
	-- if 1 then hourly, 2 then daily, 3 then weekly, 4 then monthly, etc
	-- go get start and end dates for the last recurrence .. or cheat for testing ..
	set @startdate = cast('01/21/2019' as datetime)
	set @enddate = cast('01/21/2019' as datetime)

	if (select distinct cobranding from customers where customercode = @reportcode) = 1 begin
		set @cobrand = 1
	end

	set @Parameters = (select concat('<ParameterValues><ParameterValue><Name>location</Name><Value>', @reportcode,
		'</Value></ParameterValue><ParameterValue><Name>endDate</Name><Value>', @enddate,
		'</Value></ParameterValue><ParameterValue><Name>startDate</Name><Value>', @startdate,
		'</Value></ParameterValue><ParameterValue><Name>cobrand</Name><Value>', @cobrand,
		'</Value></ParameterValue></ParameterValues>'))

	begin try
		exec [reporting].[dbo].[CreateSubscription] @id, @Locale, @Report_Name, @ReportZone, @OwnerSid, @OwnerName, @OwnerAuthType, @DeliveryExtension, @InactiveFlags, @ExtensionSettings,
		@ModifiedBySid, @ModifiedByName, @ModifiedByAuthType, @ModifiedDate, @Description, @LastStatus, @EventType, @MatchData, @Parameters, @DataSettings, @Version

		insert into [reporting].[dbo].[ReportSchedule] (ScheduleID, ReportID, SubscriptionID, ReportAction) 
		values (json_value(@json, '$.scheduleid'), json_value(@json, '$.reportid'), @id, 4)

		insert into subscriptions (subscriptionid, scheduleid, contactid, reportid, formatid, reportcode, active)
		values (@id, json_value(@json, '$.scheduleid'), json_value(@json, '$.contactid'), json_value(@json, '$.reportid'), json_value(@json, '$.formatid'), @reportcode, json_value(@json, '$.active'))

		select @id
		return
	end try

	begin catch
		select error_message()
		return
	end catch
end
go
