use distribution
go

set ansi_nulls on
go
set quoted_identifier on
go

-- =============================================================
-- Author:		Tim Halbert (tim@halberthub.com)
-- Create date: 01/23/2019
-- Description:	Return existing distribution formats
-- =============================================================

alter procedure sp_get_distribution_formats
as
begin
	set nocount on

    declare @json nvarchar(max) = (select row_number() over (order by formatname asc) as formatsort, formatid, formatname from formats for json path)
    select @json
end
go
