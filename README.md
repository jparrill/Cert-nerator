Cert-nerator
=
This tool is a Massively Certificate Generator, it make with a CA Public Key and CA Private Key all the certs that you need easy-mode.

## Requirements
+ OpenSSL
+ Keytool (from Java)

### The output box will contain the next types of certs, for iteration:
+ DER
+ CERT
+ PKCS12
+ CSR
+ JKS 

## How it works?
First make a Git clone of this repo and go inside of CA folder.
Now you must to create a CA Public and Private key:

```
 openssl req -new -x509 -days 3650 -extensions v3_ca -keyout private/cakey.pem -out cacert.pem -config ./openssl.cnf
```

Well, now you have all the necessary to start.

Now go to root folder, and edit the cert_details function with your preferences to generate the certs, change the value of "certs_to_make" variable and type this:

```
bash Masive_cert_gen.sh
```

### Example of index File:

````
V       230817161005Z           01      unknown /C=ES/ST=Madrid/O=Test/CN=cert_Org_001/emailAddress=test@email.com
V       230817161007Z           02      unknown /C=ES/ST=Madrid/O=Test/CN=cert_Org_002/emailAddress=test@email.com
V       230817161009Z           03      unknown /C=ES/ST=Madrid/O=Test/CN=cert_Org_003/emailAddress=test@email.com
````

## Notes:
* The Password inside of script and the Openssl config file must be the same
* Feel free to modify all options that you need of Openssl config file
* Take care with special characters in the password field in config file
 
