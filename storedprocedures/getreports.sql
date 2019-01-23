use distribution
go

set ansi_nulls on
go
set quoted_identifier on
go

-- =============================================================
-- Author:		Tim Halbert (tim@halberthub.com)
-- Create date: 01/23/2019
-- Description:	Return existing distribution reports
-- =============================================================

create procedure sp_get_distribution_reports
as
begin
	set nocount on

    declare @json nvarchar(max) = (select row_number() over (order by reportname asc) as reportsort, reportid, reportname from reports for json path)
    select @json
end
go
