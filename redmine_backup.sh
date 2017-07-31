#!/bin/bash
#
# Backups redmine attachments and database to a given location 
# Copyright (C) 2017  Robert Pilstål
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see <http://www.gnu.org/licenses/>.
set -e;

# Number of settings options
NUMSETTINGS=5;
# If you require a target list, of minimum 1, otherwise NUMSETTINGS
let NUMREQUIRED=${NUMSETTINGS};

# I/O-check and help text
if [ $# -lt ${NUMREQUIRED} ]; then
  echo "USAGE: [BACKUP_NAME=] $0 <user> <password> <db> <from> <to>";
  echo "";
  echo " OPTIONS:";
  echo "  user     - database user";
  echo "  password - database user password";
  echo "  db       - mysql database";
  echo "  from     - redmine root";
  echo "  to       - backup root";
  echo "";
  echo " ENVIRONMENT:";
  echo "  BACKUP_NAME - explicitly set backup name,";
  echo "                default=`date +%Y%m%d`_redmine_backup";
  echo "";
  echo " EXAMPLES:";
  echo "  # Run on default redmine (archlinux), into dropbox folder";
  echo "  $0 redmine defaultpw redmine /usr/share/webapps/redmine/ ${HOME}/Dropbox/redmine ";
  echo "";
  echo "redmine_backup  Copyright (C) 2017  Robert Pilstål;"
  echo "This program comes with ABSOLUTELY NO WARRANTY.";
  echo "This is free software, and you are welcome to redistribute it";
  echo "under certain conditions; see supplied General Public License.";
  exit 0;
fi;

# Parse settings
user=$1;
password=$2;
redmine_db=$3;
redmine_root=$4;
backup_root=$5;

# Set default values
if [ -z ${BACKUP_NAME} ]; then
  BACKUP_NAME="`date +%Y%m%d`_redmine_backup";
fi

# Create dir
backup_dir=${backup_root}/${BACKUP_NAME}
mkdir -p ${backup_dir};

# Back up
mysqldump -u ${user} --password=${password} ${redmine_db} \
  | gzip > ${backup_dir}/database.gz;
rsync -a ${redmine_root}/files/ ${backup_dir}/files/;

# Pack up
tar -czPf ${backup_dir}/files.tar.gz ${backup_dir}/files;

# Clean up
rm -r ${backup_dir}/files;
