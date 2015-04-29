#############################################################################
#                                                                           #
# win-ca-installer-formula - installs certificates from pillar data on a    #
# windows system that can run powershell commands                           #
#                                                                           #
#############################################################################

#
# Retrieve relevant pillar and grain data
#
{% set data_dir = salt['grains.get']('certificate_data_dir', 'c:\\salt-data\\certificates\\') %}
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
win-ca-installer-{{certname}}:
  cmd.run:
    - name: >
        $pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2;
        $certPath = "{{data_dir}}/{{certname}}.crt";
        $pfxPass = "";
        $pfx.import($certPath,$pfxPass,"Exportable,PersistKeySet");
        $store = new-object System.Security.Cryptography.X509Certificates.X509Store([System.Security.Cryptography.X509Certificates.StoreName]::Root,"localmachine");
        $store.open("MaxAllowed");
        $store.add($pfx);
        $store.close();

    - shell: powershell
    - unless: >
        $pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2;
        $certPath = "{{data_dir}}/{{certname}}.crt";
        $pfxPass = "";
        $pfx.import($certPath,$pfxPass,"Exportable,PersistKeySet");
        cd Cert:\LocalMachine\Root;
        &{If(dir | ? { $_.Thumbprint -eq $pfx.Thumbprint }) {EXIT 0} Else {EXIT 1}};

{% endfor %}