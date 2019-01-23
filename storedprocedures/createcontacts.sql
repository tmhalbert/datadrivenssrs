use distribution
go

set ansi_nulls on
go
set quoted_identifier on
go

-- =====================================================
-- Author:		  Tim Halbert (tim@halberthub.com)
-- Create date: 01/23/2019
-- Description:	Creates a new distribution contact
-- =====================================================

create procedure sp_create_distribution_contacts
	@json nvarchar(max)
as
begin
	set nocount on


	-- =====================================================
	--                     VARIABLES
	-- =====================================================

	declare @guidtbl table (guid uniqueidentifier)


	-- =====================================================
	--                       WORK
	-- =====================================================

	begin try
		insert into contacts (firstname, lastname, email, isrincludes)
			output inserted.contactid into @guidtbl
			select json_value(@json, '$.name.firstname') as firstname,
			  json_value(@json, '$.name.lastname') as lastname,
			  json_value(@json, '$.email') as email

		select guid from @guidtbl
		return
	end try
	begin catch
		if error_number() = 2627 
			begin
				select contactid from contacts where email = json_value(@json, '$.email')
			end
		return
	end catch
end
go
