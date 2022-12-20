#!/bin/sh

backup(){
  mkdir backup 2>/dev/null
  cd backup
  mkdir $1
  cp -r /etc /var /home $1/
  zip -r $1.zip $1
  gpg -c $1.zip
  sshpass $4 ssh $3@$2 -o "StrictHostKeyChecking=no" "mkdir backup 2>/dev/null;exit"
  sshpass $4 scp -o "StrictHostKeyChecking=no" "$1.zip.gpg" $3@$2:/home/$3/backup
  rm -r *
}

restore(){
  cd backup
  sshpass $4 scp -o "StrictHostKeyChecking=no" $3@$2:/home/$3/backup/"$1.zip.gpg" .
  gpg -o $1.zip -d $1.zip.gpg
  unzip $1.zip
  cp -r $1/* /
  rm -r *
}

case $1 in
  --help)
	  echo "Usage: $0 [Option] [IP] [Username] [Password]
    Options:
    --backup: Backup /etc, /var, and /home to server
    --restore: Restore backup files from server
    --help: Show this"
    ;;
  --backup)
    backup data $2 $3 $4
    ;;
  --restore)
    restore data $2 $3 $4
    ;;
  *)
    echo "Unrecognized option '$1'"
    echo "Try '$0 --help' for more information"
    ;;
esac
