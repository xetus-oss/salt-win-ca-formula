$pfx = new-object `
  System.Security.Cryptography.X509Certificates.X509Certificate2;

$pfx.import($args[0],"","Exportable,PersistKeySet");
$store = new-object `
  System.Security.Cryptography.X509Certificates.X509Store( `
  [System.Security.Cryptography.X509Certificates.StoreName]::Root, `
  "localmachine");
$store.open("MaxAllowed");
$store.add($pfx);
$store.close();