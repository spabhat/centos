echo "WELCOME to SCWEBS MDK Extra s/w Installer"

function shure(){
    if [ $# -gt 1 ] && [[ "$2" =~ ^[yY]*$ ]] ; then
        arg="[Y/n]"
        reg=$(locale noexpr)
        default=(0 1)
    else
        arg="[y/N]"
        reg=$(locale yesexpr)
        default=(1 0)
    fi
    read -p "$1 ${arg}? : " answer
    [[ "$answer" =~ $reg ]] && return ${default[1]} || return ${default[0]}
}


function scw_vhost_set(){
	echo ""
	read -p "Enter a Project Name!" projectname
	mkdir /var/www/$projectname
	mkdir /var/www/$projectname/web
	echo "<h1>Welcome to $projectname</h1>" >> /var/www/$projectname/web/index.php
	echo "<h4>This project is located in /var/www/$projectname/web</h4>" >> /var/www/$projectname/web/index.php
	echo "<h4>Project Logs are located in /var/www/$projectname/</h4>" >> /var/www/$projectname/web/index.php
	echo "<?php phpinfo(); ?>" >> /var/www/$projectname/web/index.php
	echo "
	<VirtualHost *:80>
		DocumentRoot "/var/www/$projectname/web"
		ServerName www.$projectname.scw
		ServerAlias $projectname.scw

		ErrorLog /var/www/$projectname/error.log
    		CustomLog /var/www/$projectname/access.log combined
		
		# Possible values include: debug, info, notice, warn, error, crit,
		# alert, emerg.
		LogLevel warn

		<Directory /var/www/$projectname/web>
			Options -Indexes +FollowSymLinks +MultiViews
			AllowOverride All
			Require all granted
		</Directory>

	    # Other directives to be added here
	</VirtualHost>" > /etc/httpd/sites-available/$projectname.conf
	ln -s /etc/httpd/sites-available/$projectname.conf /etc/httpd/sites-enabled/$projectname.conf
	echo "Created www.$projectname.scw AND $projectname.scw"
	echo "127.0.0.1 www.$projectname.scw" >> /etc/hosts
	echo "127.0.0.1 $projectname.scw" >> /etc/hosts
	service httpd restart
}

while :
do
	echo "Please Select a choice ..."
	echo "    6: New Vhost Project"
	echo "    x: Press x to exit"
	read INPUT_STRING
  case $INPUT_STRING in
	6)
		echo "Creating new vhost project!"
		scw_vhost_set
		;;
	7)
		echo "setting up SE Linux"
		scw_semod
		;;
	x)
		echo "Closing... BYE!"
		break
		;;
	*)
		echo "Sorry, I don't understand"
		;;
  esac
done
echo 
echo "That's all folks!"
