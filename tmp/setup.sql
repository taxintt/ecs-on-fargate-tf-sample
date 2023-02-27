-- mysql -h <write_endpoint> -u admin -p (password: (random string))

-- 1. confirm default user
select host, user from mysql.user;

-- 2. setup > user
create user sbcntruser@'%' identified by 'sbcntrEncP';
grant all on sbcntrapp.* to sbcntruser@'%' with grant option;

create user migrate@'%' identified by 'sbcntrMigrate';
grant all on sbcntrapp.* to migrate@'%' with grant option;
grant all on `prisma_migrate_shadow_db%`.* to migrate@'%' with grant option;

select host, user from mysql.user;

-- 3. setup > table and initial data
-- mysql -h <write_endpoint> -u sbcntruser -p 
-- password : sbcntrEncP
-- exit;
-- mysql -h <write_endpoint> -u migrate -p
-- password : sbcntrMigrate
-- exit;
use sbcntrapp;
show tables;

-- in cloud9 w/ sbcntr-frontend
-- git checkout main
-- export DB_USERNAME=migrate
-- export DB_PASSWORD=sbcntrMigrate
-- export DB_HOST=<write_endpoint>
-- export DB_NAME=sbcntrapp
-- npm run migrate:dev
-- npm run seed

-- 4. confirm initial data
-- mysql -h <write_endpoint> -u sbcntruser -p 
use sbcntrapp;
show tables;
select * from Notification;