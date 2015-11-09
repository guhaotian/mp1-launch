#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y apache2 git php5 php5-curl mysql-client curl php5-mysql 

git clone https://github.com/guhaotian/mp1-php.git
mv ./mp1/gallery.php /var/www/html
mv ./mp1/index.php /var/www/html
mv ./mp1/submit.php /var/www/html
mv ./mp1/setup.php /var/www/html


#curl -sS https://getcomposer.org/installer | sudo php &> /tmp/getcomposer.txt

#sudo php composer.phar require aws/aws-sdk-php &> /tmp/runcomposer.txt

#sudo mv vendor /var/www/html &> /tmp/movevendor.txt

#sudo php /var/www/html/setup.php &> /tmp/database-setup.txt


echo "Hello!" > /tmp/hello.txt
