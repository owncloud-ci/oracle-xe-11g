create user autotest identified by owncloud;
alter user autotest default tablespace users
temporary tablespace temp
quota unlimited on users;
grant create session
, create table
, create procedure
, create sequence
, create trigger
, create view
, create synonym
, alter session
to autotest;

quit;
/
