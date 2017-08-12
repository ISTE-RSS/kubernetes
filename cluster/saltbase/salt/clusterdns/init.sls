{% if grains['roles'][0] == 'kubernetes-master' -%}
dnsmasq:
  pkg:
    - installed
    - require_in:
      - service: dyndns

nmap-ncat:
  pkg:
    - installed
    - require_in:
      - service: dyndns
    
/etc/dnsmasq.conf:
  file.managed:
    - source: salt://clusterdns/dnsmasq.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - require_in:
      - service: dyndns
      
/etc/local-dyndns.conf:
  file.managed:
    - source: salt://clusterdns/local-dyndns.conf
    - user: root
    - group: root
    - mode: 600
    - makedirs: true
    - require_in:
      - service: dyndns
 
/etc/systemd/system/dyndns.service:
   file.managed:
     - source: salt://clusterdns/dyndns.service
     - user: root
     - group: root
     - mode: 644
     - makedirs: true
     - require_in:
       - service: dyndns

/usr/bin/dyndns-server.sh:
   file.managed:
     - source: salt://clusterdns/dyndns-server.sh
     - user: root
     - group: root
     - mode: 755
     - makedirs: true
     - require_in:
       - service: dyndns
               
/usr/bin/local-dyndns-listen:
   file.managed:
     - source: salt://clusterdns/local-dyndns-listen
     - user: root
     - group: root
     - mode: 755
     - makedirs: true
     - require_in:
       - service: dyndns
       
dyndns:
  service:
    - running
    - name: dyndns
    - watch:
      - file: /usr/bin/local-dyndns-listen
      - file: /usr/bin/dyndns-server.sh
      - file: /etc/systemd/system/dyndns.service
      - file: /etc/local-dyndns.conf
    - require_in:
      - file: /etc/dhcp/dhclient.conf

{% else %}

/usr/bin/register_machine.sh:
   file.managed:
     - source: salt://clusterdns/register_machine.sh
     - user: root
     - group: root
     - mode: 755
     - makedirs: true

Run myscript:
  cmd.run:
    - name: /usr/bin/register_machine.sh
    - cwd: /
    - watch:
      - file: /usr/bin/register_machine.sh
      
{% endif %}
    
/etc/dhcp/dhclient.conf:
  file.replace:
    - name: /etc/dhcp/dhclient.conf
    - repl: "supersede domain-name-servers 10.0.0.3;"
    - append_if_not_found: True
    - pattern: "^supersede .*"

Run dhcp reload script:
  cmd.run:
    - name: dhclient -r && dhclient
    - cwd: /
    - onchange:
      - file: /etc/dhcp/dhclient.conf