use distribution
go

set ansi_nulls on
go
set quoted_identifier on
go

-- =============================================================
-- Author:		Tim Halbert (tim@halberthub.com)
-- Create date: 01/23/2019
-- Description:	Return existing distribution subscriptions
--                  by report code or subscription email
-- =============================================================

create procedure sp_get_distribution_subscriptions
    @reportcode nvarchar(260),
    @email nvarchar(260)
as
begin
	set nocount on

    declare @json nvarchar(max) = (
        select sb.subscriptionid,
            sh.schedulename,
            cn.email,
            rp.reportname,
            fr.formatname,
            sb.reportcode
        from subscriptions sb
        join schedules sh
            on sh.scheduleid = sb.scheduleid
        join contacts cn
            on cn.contactid = sb.contactid
        join reports rp
            on rp.reportid = sb.reportid
        join formats fr
            on fr.formatid = sb.formatid
        where sb.active = 1 and (
            sb.reportcode = @reportcode or
            cn.email = @email)
        for json path)

    select @json
end
go
