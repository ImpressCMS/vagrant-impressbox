@echo off

if "%1" == "" goto show_help
goto run

:show_help
echo ----------------------------------------------------
echo Use: %0 BOX_TYPE
echo ----------------------------------------------------
bundle exec vagrant impressbox --help
goto:eof

:run
call bundle
call bundle exec vagrant destroy -f
call rm -rf www
call bundle exec vagrant impressbox -t %1 -r
call bundle exec vagrant up
goto:eof
