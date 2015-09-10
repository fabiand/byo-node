
Build
-----

- `bash ci/build.sh`
- `service firewalld stop && python -m SimpleHTTPServer`

Deployment
----------

- Start with CentOS 7 Atomic
- Add a new remote with this trees
- Use `ostree admin switch <remote>:centos/7/x86_74/ovirt/host/ovirt-3.5` to switch to the tree
- Reboot
- Add host to Engine through Engine

Update
------

- Put host into maintenance
- `ostree admin update`
