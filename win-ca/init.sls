#############################################################################
#                                                                           #
# win-ca-formula - installs certificates from pillar data on a              #
# windows system that can run powershell commands                           #
#                                                                           #
#############################################################################

#
# Retrieve relevant pillar and grain data
#
{% set data_dir = salt['pillar.get'](
    'certificate_data_dir', 
    'c:\\salt-data\\certificates\\') %}

{% set certificates = salt['pillar.get']('win_ca:certificates') %}

#
# Allow for multiple certificates to be loaded
#
{% for certname, certcontents in certificates.iteritems() %}

#
# place the certificate contents in a managed file to load using powershell
# commands
#
{{data_dir}}\{{certname}}.crt:
  file.managed:
    - contents: |
        {{certcontents | indent(8) }} 
    - makedirs: True

# 
# Loads the certificate into the "Trusted Root Certification Authorities"
# trusted store.
#
# Will not load the certificate if the fingerprint matches an existing
# certificate in the store
# 
salt://win-ca/powershell/ca_install.ps1:
  cmd.script:
    - args: ' {{data_dir}}\{{certname}}.crt'
    - shell: powershell
    - unless: EXIT {{ salt['cmd.script'](
        'salt://win-ca/powershell/ca_verify.ps1', args=(' ' + 
        data_dir + '/' + certname + '.crt'), shell="powershell").retcode }}

{% endfor %}