#!/bin/bash

my_dir=$(cd $(dirname $0); pwd)

check_dbnas () {
    [ $(grep -v ^# /etc/hosts |grep -c DBNAS) -eq 0 ] &&
        echo -e "\n172.16.217.223\tnfsServer.com DBNAS" >> /etc/hosts
}

dbnas_mount() {
    [ $(df -k |grep -c Backup_Temp) -eq 0 ] &&
        check_dbnas &&
        mount DBNAS:/vol/vol10/shared_dir /net/Backup_Temp 
}

set_sudo_nopass() {
    FILE=/etc/sudoers
    ROW=$(grep -n %wheel $FILE |grep ": *#" |grep NOPASSWD |cut -d: -f1)
    if [ $ROW ]; then
        sed -i 's/^ *%wheel/# %wheel/' $FILE
        sed -i $ROW's/^ *# *//' $FILE &&
            echo "[sudo] NOPASS was configured successfully."
    else
        echo "- [sudo] NOPASS has been already configured. [OK]"
    fi
}

add_user_ansible() {
    useradd -u 2002 -U -G wheel ansible &&
        echo "[ansible] User was successfully added."
    echo "ansible:dosTjqmf" |chpasswd

    dbnas_mount
    mkdir /home/ansible/.ssh && 
        chown ansible:ansible /home/ansible/.ssh

    su - ansible -c "cat ${my_dir}/id_rsa.pub >> /home/ansible/.ssh/authorized_keys"
}

__main__() {
    if [ $(grep -c ^ansible /etc/passwd) -eq 0 ]; then
        [ ! -f ${my_dir}/id_rsa.pub ] &&
            dbnas_mount
        add_user_ansible
    elif [ -f /home/ansible/.ssh/authorized_keys -a $(grep -v ^# /home/ansible/.ssh/authorized_keys |grep -c Ansible-Server) -gt 0 ]; then
        echo "- [ansible] User has been already existed. [OK]"
    else
        [ ! -d /home/ansible/.ssh ] && mkdir /home/ansible/.ssh && chown ansible:ansible /home/ansible/.ssh
        su - ansible -c "cat ${my_dir}/id_rsa.pub >> /home/ansible/.ssh/authorized_keys"
    fi
    set_sudo_nopass
}
__main__