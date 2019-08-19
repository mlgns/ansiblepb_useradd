# ansiblepb_useradd playbook (pre-alpha v. 0.000001)
Create user for ldap, mail (zimbra), owncloud and OpenVPN config files. Send config files to new mail.

### setup

Put manual scripts on dirs:

```
1) ldap /root/ldap/ldapuser.sh
2) zimbra (mail)  /root/mailuser.sh
3) files (owncloud) /root/filesuser.sh
4) openvpn  ~/keygen/scripts//root/keygen/scripts/openvpnfiles_gen.sh
```

After that you have to change inventory hostnames
example: 
```
ldap 0.0.0.1 
zimbra 0.0.0.2
files 0.0.0.3
openvpn 0.0.0.4
```
### run

```
$ ansible-playbooks newuser.yml
```
