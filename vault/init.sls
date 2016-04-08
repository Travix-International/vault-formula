{% from "vault/map.jinja" import vault with context %}

include:
  - vault.install
  - vault.config
  - vault.service
