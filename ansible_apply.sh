export ANSIBLE_HOST_KEY_CHECKING=False
# https://stackoverflow.com/questions/42462435/ansible-provisioning-error-using-a-ssh-password-instead-of-a-key-is-not-possibl
# https://www.geeksforgeeks.org/devops/disabling-host-key-checking-in-ansible/
ansible-playbook -i inventory playbook.yaml
./connect.sh
