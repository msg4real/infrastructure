base:
  '*':
    - defaults

  'not bootstrap':
    - freeipa_client_secret
    - ignore_missing: True

  'mcp or bootstrap':
    - mcp

  'mcp':
    - digitalocean_secret
    - mcp_secret
    - magbot_secret
    - slack_irc_secret
    - ignore_missing: True

  'archive.uber.magfest.org':
    - archive_uber_magfest_org

  'backups.uber.magfest.org':
    - backups_uber_magfest_org

  'docker.uber.magfest.org':
    - docker_uber_magfest_org

  'G@is_vagrant:True':
    - vagrant