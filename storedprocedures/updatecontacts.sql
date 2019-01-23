use distribution
go

set ansi_nulls on
go
set quoted_identifier on
go

-- =====================================================
-- Author:		  Tim Halbert (tim@halberthub.com)
-- Create date: 01/23/2019
-- Description:	Updates an existing distribution contact
-- =====================================================

alter procedure sp_update_distribution_contacts
	@json nvarchar(max)
as
begin
	set nocount on

	begin try
      update contacts 
        set firstname = json_value(@json, '$.name.firstname'),
            lastname = json_value(@json, '$.name.lastname'),
            email = json_value(@json, '$.email')

		select @@rowcount
		return
	end try
	begin catch
		select error_message()
		return
	end catch
end
go
