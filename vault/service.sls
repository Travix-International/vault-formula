{% from "vault/map.jinja" import vault with context %}

vault-init-script:
  file.managed:
    {% if salt['test.provider']('service') == 'upstart' %}
    - source: salt://vault/files/vault.upstart
    - name: /etc/init/vault.conf
    - mode: 0644
    {% else %}
    - source: salt://vault/files/vault.sysvinit
    - name: /etc/init.d/vault
    - mode: 0755
    {% endif %}
    {% if vault.service != False %}
    - watch_in:
       - service: vault
    {% endif %}

{% if vault.service != False %}
vault-service:
  service.running:
    - name: vault
{% endif %}
