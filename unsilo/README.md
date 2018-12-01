# Unsilo

root@honcho2 [~]# sudo chmod 777 /usr/bin/gcc
root@honcho2 [~]# sudo chmod 777 /usr/bin/ld
root@honcho2 [~]# sudo chmod 640 /usr/bin/gcc
root@honcho2 [~]# sudo chmod 640 /usr/bin/ld
root@honcho2 [~]# 

mix edeliver build release
mix edeliver deploy release production

