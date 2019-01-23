use distribution
go

set ansi_nulls on
go
set quoted_identifier on
go

-- =====================================================
-- Author:		  Tim Halbert (tim@halberthub.com)
-- Create date: 01/23/2019
-- Description:	Merges application customers into
--    distribution database
-- =====================================================

create procedure sp_upsert_distribution_customers
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

	declare @tempcustomers table (
		customerid uniqueidentifier,
		customername nvarchar(260),
		customercode nvarchar(260)
	);

	insert into @tempcustomers (customerid, customername, customercode, matpath)
		select distinct
		  cast(cast(location_code as binary(16)) as uniqueidentifier) as customerid,
		  location_name as customername,
		  location_code as customercode
		from [application].[dbo].[customers]

	merge into customers as target
		using @tempcustomers as source
			on target.customerid = source.customerid
		when matched and (
					target.customername != source.customername
				) then
			update set target.customername = source.customername
		when not matched then
			insert (customerid, customername, customercode)
				values (source.customerid, source.customername, source.customercode);

  set @rowcount = @@rowcount
  select @rowcount
end
go
