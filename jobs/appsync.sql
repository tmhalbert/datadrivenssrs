use msdb

exec sp_add_job
  @job_name = 'appsync',
  @enabled = 1,
  @description = 'Sync needed data from company application db into "distribution" DB'

exec sp_add_jobstep
  @job_name = 'appsync',
  @step_name = 'synccustomers',
  @subsystem = 'TSQL',
  @command = 'exec [distribution].[dbo].[sp_upsert_distribution_customers]',
  @retry_attempts = 5,
  @retry_interval = 5

exec sp_add_jobserver
  @job_name = 'appsync'