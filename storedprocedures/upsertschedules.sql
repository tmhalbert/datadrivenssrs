use distribution
go

set ansi_nulls on
go
set quoted_identifier on
go

-- =====================================================
-- Author:		  Tim Halbert (tim@halberthub.com)
-- Create date: 01/23/2019
-- Description:	Merges SSRS Shared Schedules into
--    the schedules in the distribution database
-- =====================================================

create procedure sp_upsert_distribution_schedules
as
begin
	set nocount on;


	-- =====================================================
	--                     VARIABLES
	-- =====================================================

	declare @rowcount int;


	-- =====================================================
	--                       WORK
	-- =====================================================

  merge into schedules as target
    using [reporting].[dbo].[Schedule] as source
      on target.scheduleid = source.ScheduleID
    when matched and (target.schedulename != source.Name collate Latin1_General_100_CI_AS_KS_WS
        or target.recurrence <> source.RecurrenceType or target.lastruntime <> source.LastRunTime) then
      update set target.schedulename = source.Name, target.recurrence = source.RecurrenceType,
        target.lastruntime = source.LastRunTime
    when not matched and (source.Type = 0 and source.State = 1) then
      insert (scheduleid, schedulename, recurrence, lastruntime)
        values (source.ScheduleID, source.Name, source.RecurrenceType, source.LastRunTime);

  set @rowcount = @@rowcount
  select @rowcount
end
go
