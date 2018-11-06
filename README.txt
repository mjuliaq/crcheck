# crcheck.sh run-once install instructions 

# From your home directory, add RANCID bin directory to your environment PATH 
# variable and your .bashrc file

cd
echo PATH=\$PATH:/usr/local/rancid/bin >> .bashrc
PATH=$PATH:/usr/local/rancid/bin

# Create a .cloginrc file in your home directory, replace below username and
# password with your tacacs username and password

cat >> .cloginrc <<_CLOGINRC

add user        *       username 			# no brackets
add password    *       {password} {password}
add method      *       {ssh} {telnet}
_CLOGINRC

# Change permissions of your cloginrc file so it is only readble by you.
# Otherwise clogin will refuse to run.

chmod 600 .cloginrc 

# To execute the script ensure it is executable and provide a prefix for the log files

chmod 755 crqchecks.sh

./crqchecks.sh CR1212_checks
