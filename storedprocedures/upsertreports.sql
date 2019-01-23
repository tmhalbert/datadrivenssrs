use distribution
go

set ansi_nulls on
go
set quoted_identifier on
go

-- =====================================================
-- Author:		  Tim Halbert (tim@halberthub.com)
-- Create date: 01/23/2019
-- Description:	Merges SSRS Report Items into
--    reports in the distribution database
-- =====================================================

create procedure sp_upsert_distribution_reports
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

	merge into reports as target
	  using [reporting].[dbo].[Catalog] as source
	    on target.reportid = source.ItemID
	  when matched and (target.reportname != source.Name collate Latin1_General_100_CI_AS_KS_WS
	      or target.parameters != cast(source.Parameter as nvarchar(max)) collate Latin1_General_100_CI_AS_KS_WS) then
	    update set target.reportname = source.Name, target.parameters = source.Parameter
	  when not matched and (source.Type = 2) then
	    insert (reportid, reportname, parameters)
	      values (source.ItemID, source.Name, source.Parameter);

  set @rowcount = @@rowcount
  select @rowcount
end
go
