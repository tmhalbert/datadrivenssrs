use distribution
go

set ansi_nulls on
go
set quoted_identifier on
go

-- =============================================================
-- Author:		Tim Halbert (tim@halberthub.com)
-- Create date: 01/23/2019
-- Description:	Return existing distribution contacts
-- =============================================================

create procedure sp_get_distribution_contacts
as
begin
	set nocount on

    declare @json nvarchar(max) = (select contactid, email from contacts for json path)
    select @json
end
go
