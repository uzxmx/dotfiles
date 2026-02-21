#!/bin/sh

# Create a cron job file.
#
# @params:
#   $1: file name
#   $2: schedule pattern
#   $3: function to generate shell script content
create_cron_job_file() {
  local name="$1"
  lcoal schedule_pattern="$2"

  local cron_dir="$DOTFILES_TARGET_DIR/opt/my_cron_jobs"
  mkdir -p "$cron_dir"
  local cron_job_file="$cron_dir/$name.sh"

  # Generate shell script content
  $3 "$cron_job_file"

  chmod a+x "$cron_job_file"

  local croncmd="\"$cron_job_file\""

  # Example of job definition:
  # .---------------- minute (0 - 59)
  # |  .------------- hour (0 - 23)
  # |  |  .---------- day of month (1 - 31)
  # |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
  # |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
  # |  |  |  |  |
  # *  *  *  *  * user-name command to be executed
  ( crontab -l | grep -v -F " $croncmd" ; echo "$schedule_pattern $croncmd" ) | crontab -
}
