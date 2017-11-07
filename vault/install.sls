{% from "vault/map.jinja" import vault with context %}

unzip:
  pkg.installed

/usr/local/bin:
  file.directory:
    - makedirs: True

# Create vault user
vault-user:
  group.present:
    - name: vault
  user.present:
    - name: vault
    - createhome: false
    - system: true
    - groups:
      - vault
    - require:
      - group: vault

# Create directories
vault-config-dir:
  file.directory:
    - name: /etc/vault.d
    - user: vault
    - group: vault
    - require:
      - user: vault

vault-runtime-dir:
  file.directory:
    - name: /var/vault
    - user: vault
    - group: vault
    - require:
      - user: vault

vault-data-dir:
  file.directory:
    - name: /usr/local/share/vault
    - user: vault
    - group: vault
    - makedirs: 
    - require:
      - user: vault

# Install vault
vault-download:
  file.managed:
    - name: /tmp/vault_{{ vault.version }}_linux_amd64.zip
    - source: https://releases.hashicorp.com/vault/{{ vault.version }}/vault_{{ vault.version }}_linux_amd64.zip
    - source_hash: sha256={{ vault.hash }}
    - unless: test -f /usr/local/bin/vault-{{ vault.version }}

vault-extract:
  cmd.wait:
    - name: unzip /tmp/vault_{{ vault.version }}_linux_amd64.zip -d /tmp
    - watch:
      - file: vault-download

vault-install:
  file.rename:
    - name: /usr/local/bin/vault-{{ vault.version }}
    - source: /tmp/vault
    - require:
      - file: /usr/local/bin
    - watch:
      - cmd: vault-extract

vault-clean:
  file.absent:
    - name: /tmp/vault_{{ vault.version }}_linux_amd64.zip
    - watch:
      - file: vault-install

vault-link:
  file.symlink:
    - target: vault-{{ vault.version }}
    - name: /usr/local/bin/vault
    - watch:
      - file: vault-install

vault-set-cap-mlock:
  cmd.run:
    - name: "setcap cap_ipc_lock=+ep $(readlink -f $(which vault))"
    - unless: {{ vault.config.disable_mlock }}
    - watch:
      - file: vault-install

vault-log-file:
  file.managed:
    - name: /var/log/vault.log
    - user: {{ vault.user }}
    - group: {{ vault.group }}
    - mode: 0644
    - require:
      - file: vault-install

vault-audit-log-file:
  file.managed:
    - name: /var/log/vault-audit.log
    - user: {{ vault.user }}
    - group: {{ vault.group }}
    - mode: 0600
    - require:
      - file: vault-install
