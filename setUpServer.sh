echo "WELCOME to SCWEBS Extra s/w Installer"
echo "Make sure you are logged in with Admin rights"

function areYouShure(){
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

function scw_default_setup(){
	yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
	yum install yum-utils
	yum-config-manager --enable remi-php72	
	rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
	yum-config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
	yum install sublime-text
	yum install geany
	firewall-cmd --permanent --zone=public --add-service=http
	firewall-cmd --permanent --zone=public --add-service=https
	firewall-cmd --reload
	cd /tmp
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
	sudo yum install ./google-chrome-stable_current_*.rpm
}
function scw_semod(){
	setsebool -P httpd_unified 1
	ausearch -c 'httpd' --raw | audit2allow -M my-httpd
	semodule -i my-httpd.pp
}
function scw_install_php(){
	yum install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-mbstring
	echo "Installing additional php librries"
	yum install php-bcmath php-fedora-autoloader php-php-gettext php-tcpdf php-tcpdf-dejavu-sans-fonts php-tidy
}
function scw_install_mysql(){
	yum install mariadb mariadb-server
	service mariadb start
	echo "NOW set root password as >>>>>>>>>>> 'scwebs@info'"
	read -p "Press any key to proceed!"
	/usr/bin/mysql_secure_installation
	yum install phpMyAdmin
}
function scw_share_phpMyAdmin(){
	echo "This allows remote access to PHPMYADMIN"
	echo " under the section
		<IfModule mod_authz_core.c>
			<RequireAny>
		       		# ##### ADD following line
       				Require all granted
				.....
				.....
			</RequireAny>"
	read -p "Press any key to proceed!"
	nano /etc/httpd/conf.d/phpMyAdmin.conf
}
function scw_vhost_dirs(){
	mkdir /etc/httpd/sites-available
	mkdir /etc/httpd/sites-enabled
	scw_enable_vhostdirs
}
function scw_enable_vhostdirs(){	
	echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf
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

<<commentx
if areYouShure "Would you like default setup?"; then
	default_setup
fi
if areYouShure "Install PHP?"; then
	install_php
fi
if areYouShure "Install MySQL?"; then
	install_mysql
fi
if areYouShure "Do you need Remote PHPMyAdmin access?"; then
	share_phpMyAdmin
fi
commentx

while :
do
	echo "Please Select a choice ..."
	echo "    1: Default Setup"
	echo "    2: Install PHP"
	echo "    3: Install MySQL"
	echo "    4: Setup Remote PHPMyAdmin Access"
	echo "    5: Make Vhost Directories"
	echo "    6: New Vhost Project"
	echo "    7: Fix selinux"
	echo "    x: Press x to exit"
	read INPUT_STRING
  case $INPUT_STRING in
	1)
		echo "Starting Default setup!"
		scw_default_setup
		echo "Default setup completed (1)"
		;;
	2)
		echo "Installing php!"
		scw_install_php
        echo "PHP Instllation completed (1)"
		;;
	3)
		echo "Installing MySQL!"
		scw_install_mysql
		;;
	4)
		echo "Setting up remote PHPMyAdmin Access!"
		scw_share_phpMyAdmin
		;;
	5)
		echo "Creating vhost dirs!"
		scw_vhost_dirs
		;;
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
