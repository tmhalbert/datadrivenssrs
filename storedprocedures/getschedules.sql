use distribution
go

set ansi_nulls on
go
set quoted_identifier on
go

-- =============================================================
-- Author:		Tim Halbert (tim@halberthub.com)
-- Create date: 01/23/2019
-- Description:	Return existing distribution schedules
-- =============================================================

alter procedure sp_get_distribution_schedules
as
begin
	set nocount on

    -- recurrence - 2 gives my setup with an hourly, daily, weekly, monthly, etc. shared schedules a sort starting at 1 - hourly 
    declare @json nvarchar(max) = (select recurrence - 2 as schedulesort, scheduleid, schedulename from schedules for json path)
    select @json
end
go
