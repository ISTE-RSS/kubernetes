add-dm-thin-pool:
  kmod.present:
    - name: dm_thin_pool
    - persist: True
    
additional-custom-repos:
  pkg.installed:
    - pkgs:
      - centos-release-gluster310
    - require_in:
      - pkg: additional-custom-pkgs
      
additional-custom-pkgs:
   pkg.installed:
     - pkgs:
       - tcpdump
       - nano
       - bind-utils
       - glusterfs
       - glusterfs-fuse
       - attr
       - glusterfs-libs
       
pkg.upgrade:
    module.run:
        - refresh: True
    