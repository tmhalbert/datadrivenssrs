use distribution
go

set ansi_nulls on
go
set quoted_identifier on
go

-- =============================================================
-- Author:		  Tim Halbert (tim@halberthub.com)
-- Create date: 01/23/2019
-- Description:	Return existing distribution customers
-- =============================================================

alter procedure sp_get_distribution_report_codes
as
begin
	set nocount on

  declare @json nvarchar(max) = (select customerid, customername, customercode from customers for json path)
  select @json
end
go
