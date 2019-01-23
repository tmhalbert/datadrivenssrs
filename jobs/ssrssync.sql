use msdb

exec sp_add_job
  @job_name = 'ssrssync',
  @enabled = 1,
  @description = 'Sync needed data from SSRS "reporting" DB into "distribution" DB'

exec sp_add_jobstep
  @job_name = 'ssrssync',
  @step_name = 'syncschedules',
  @subsystem = 'TSQL',
  @command = 'exec [distribution].[dbo].[sp_upsert_distribution_schedules]',
  @retry_attempts = 5,
  @retry_interval = 5

exec sp_add_jobstep
  @job_name = 'ssrssync',
  @step_name = 'syncreports',
  @subsystem = 'TSQL',
  @command = 'exec [distribution].[dbo].[sp_upsert_distribution_reports]',
  @retry_attempts = 5,
  @retry_interval = 5

exec sp_add_jobserver
  @job_name = 'ssrssync'