# AIX 7.2 handover

Ansible playbooks to run before handover to project teams

# How to use these playbooks

1. Installation

```
ansible-galaxy collection install community.general
ansible-galaxy collection install ibm.power_aix
```

Add AIX hosts to the inventory file 'hosts'.

2. Run the pre-handover playbook 'handover_pre.yaml'. It runs following playbooks sequentially:
...aix_7.2_post_script.yaml (Post script after AIX 7.2 installation)
...crjfs2log.yaml (Create jfs2log)
...crsysfs-sybase16.yaml (Create file systems)
...restore.yaml (Restore files from tar ball)
...login_reset_users.yaml (Reset user login counts)
...pwdhist_delete_users.yaml (Delete user password history)

```
ansible-playbook -i hosts handover_pre.yaml
```

3. Run a sighle playbook. Each playbook can be run separately. e.g.

```
ansible-playbook -i hosts crjfs2log.yaml
```

4. Run the handover check playbook 'handover_chk.yaml'. It checks just one AIX host per run, so only **ONE** host should be defined in the inventory file 'hosts'.

```
ansible-playbook -i hosts handover_chk.yaml
```


About handover ansible version:
a1.x is about nim, altdisk, nmon log file operation
a2.x included LPAR creation and SAN zoning.![image](https://github.com/IBMLBSHK/handover/assets/117252002/b91bd77f-42e3-45f0-ae0b-43ee377d06be)

