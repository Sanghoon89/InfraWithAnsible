# Add User & Group
1. 해당 User 있는지 체크
    > [ "\$(id ${USER} 2>/dev/null)" ] && echo OK || echo Not    
1. 해당 User의 uid 체크
    > [ "\$(cat /etc/passwd |cut -d: -f3 |grep -c $UID) -gt 0 ] && echo OK || echo Not
1. 해당 User의 gid 체크
    > [ "\$(cat /etc/group |cut -d: -f3 |grep -c $GID) -gt 0) -eq 0 ] && echo OK || echo Not
1. add user
    > adduser -u $UID -g $GID -m $USER