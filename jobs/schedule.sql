use msdb

exec sp_add_schedule
  @schedule_name = 'nightlysync',
  @freg_type = 4,
  @freq_interval = 1,
  @active_start_time = 010000

exec sp_attach_schedule
  @job_name = 'ssrssync',
  @schedule_name = 'nightlysync'

exec sp_attach_schedule
  @job_name = 'appsync',
  @schedule_name = 'nightlysync'