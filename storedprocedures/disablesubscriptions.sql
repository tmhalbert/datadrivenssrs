use distribution
go

set ansi_nulls on
go
set quoted_identifier on
go

-- =============================================================
-- Author:		Tim Halbert (tim@halberthub.com)
-- Create date: 01/23/2019
-- Description:	Disables an existing distribution subscription
-- =============================================================

create procedure sp_disable_distribution_subscriptions
	@subscriptionid uniqueidentifier
as
begin
	set nocount on

    update [reporting].[dbo].[Subscriptions] set InactiveFlags = 128, LastStatus = 'Disabled', ModifiedDate = getdate() 
    where SubscriptionID = @subscriptionid

    update subscriptions set active = 0 where subscriptionid = @subscriptionid
end
go
