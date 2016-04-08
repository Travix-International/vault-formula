{% from "vault/map.jinja" import vault with context %}

vault-config:
  file.managed:
    - source: salt://vault/files/config.json
    - template: jinja
    - name: /etc/vault.d/config.json
    {% if vault.service != False %}
    - watch_in:
       - service: vault
    {% endif %}
