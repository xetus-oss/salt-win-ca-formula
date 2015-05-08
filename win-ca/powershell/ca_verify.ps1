$pfx = new-object `
  System.Security.Cryptography.X509Certificates.X509Certificate2;

$pfx.import($args[0],"","Exportable,PersistKeySet");

cd Cert:\LocalMachine\Root;
&{If(dir | ? { $_.Thumbprint -eq $pfx.Thumbprint }) `
  {EXIT 0} `
Else `
  {EXIT 1}};