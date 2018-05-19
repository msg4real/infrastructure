# ============================================================================
# Installs the FreeIPA client and configures SSH authentication
# ============================================================================

# All of our servers are intially provisioned with /root/.ssh/authorized_keys
# that are installed on MCP, so we can immediately disable password auth.
sshd disable password authentication:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^\s*PasswordAuthentication\s+yes\s*$
    - repl: PasswordAuthentication no
    - append_if_not_found: True
    - listen_in:
      - service: sshd

# Make sure that users home directories are created on initial login.
sshd create home directory on initial login:
  file.line:
    - name: /etc/pam.d/sshd
    - content: session required pam_mkhomedir.so skel=/etc/skel/ umask=0022
    - after: session\s+.+?\s+pam_selinux\.so\s+close
    - mode: ensure

# Install the FreeIPA client package. The ipa client isn't actually installed
# until the ipa-client-install script is run.
freeipa-client install:
  pkg.installed:
    - name: freeipa-client

# Install the ipa client.
ipa-client-install:
  cmd.run:
    - name: >
        ipa-client-install
        --domain={{ salt['pillar.get']('freeipa:realm')|lower }}
        --realm={{ salt['pillar.get']('freeipa:realm')|upper }}
        --principal={{ salt['pillar.get']('freeipa:client_principal') }}
        --password={{ salt['pillar.get']('freeipa:client_password') }}
        --mkhomedir
        --no-ntp
        --force-join
        --unattended
    - creates: /etc/ipa/default.conf
    - require:
      - pkg: freeipa-client

# Disables root login. We must wait until after the ipa client is installed,
# otherwise we'll end up locking ourselves out of a newly provisioned server.
sshd disable root login:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^\s*PermitRootLogin\s+yes\s*$
    - repl: PermitRootLogin no
    - append_if_not_found: True
    - listen_in:
      - service: sshd
    - require:
      - ipa-client-install
