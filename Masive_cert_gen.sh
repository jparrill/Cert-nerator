#!/bin/bash
#########################################
## Author:		Juan Manuel Parrilla
## Requires: 	Openssl
## Descrip:		This script make signed certificates with a CA, you must to create the CA + CA.key
##			How to make a CA: openssl req -new -x509 -days 3650 -extensions v3_ca -keyout private/cakey.pem -out cacert.pem -config ./openssl.cnf
#########################################
## Global Config Vals
base_dir="$(dirname $0)"
root=$base_dir/CA 			# Base Path
key=cakey.pem 				# CA Private Key
ca=cacert.pem 				# CA Public Key
config=openssl.cnf 			# OpenSSL config file
password="genera2"			# Password for all certs
certs_to_make=2 			# How many certs you will make?

## Script Values
start="$(echo "ibase=16; `cat $root/serial`" | bc)"
finish=`expr $start + $certs_to_make`

function name_definition()
{
	if [ $1 -lt 10 ];then
		num="00"$1
	elif [ $1 -lt 100 ] && [ $1 -gt 9 ];then
		num="0"$1
	else
		num=$1
	fi
	name="cert_Org_"$num
	fold_name="Org_"$num
	new_csr=`echo $name".csr"`
	new_crt=`echo $name".crt"`
	new_pfx=`echo $name".pfx"`
	new_der=`echo $name".der"`
	new_jks=`echo $name".jks"`
}

function cert_details()
{
	## This function contains the certificate detail for all new certs that you will make, 
	## CN will have a incrementally name
	O="Test"
	emailAddress="test@email.com"
	L="Madrid"
	ST="Madrid"
	C="ES"
	CN=$name
}

function check()
{
	if [ $1 != 0 ];then
		echo "Error generating certificate..."
		exit -1	
	fi	
}

function validator()
{
	## This function will make sure that all neccesary are in their place
	[ -d $root/crt ] || mkdir -p $root/crt
	[ -d $root/pfx ] || mkdir -p $root/pfx
	[ -d $root/csr ] || mkdir -p $root/csr
	[ -d $root/der ] || mkdir -p $root/der
	[ -d $root/jks ] || mkdir -p $root/jks
	[ -d $base_dir/provision ] || mkdir $base_dir/provision
	[ -e $root/$ca ] || echo "You must to create a CA with cacert.pem name"
	check $?
	[ -e $root/private/$key ] || echo "You must to create a CA key with cakey.pem name in private folder"
	check $?
	echo "It seems that all is ok, continue with the ejecution"
}

function make_der()
{
## Make DER Cert type
echo "Exporting $new_crt to DER file: $new_der"
openssl x509 -outform der -in crt/$new_crt -out der/$new_der
check $?
}

function make_jks()
{
echo "Exportig $new_pfx to JKS Filetype: $new_jks"
keytool -importkeystore -srckeystore pfx/$new_pfx -srcstoretype pkcs12 -destkeystore jks/$new_jks -deststoretype JKS <<EOF
$password
$password
$password
EOF
check $?	
}

function make_pfx()
{
## Make PKCS12 cert type
echo "Making PFX file: "$new_pfx
openssl pkcs12 -password pass:$password -passin pass:$password -export -out pfx/$new_pfx -inkey private/$key -in crt/$new_crt 	
check $?
echo ""
}

function make_crt()
{
	## Typycally cert file
echo "Making Certificate signed by "$key" named: "$new_crt 
openssl ca -key $password -out crt/$new_crt -config $config -days 3650 -infiles csr/$new_csr <<EOF
y
y
EOF
check $?
echo ""
}

function make_csr()
{
	## Make CSR to create a Cert
echo ""
echo "Making CSR named: "$new_csr
openssl req -config $config -new -key private/$key -out csr/$new_csr <<EOF
${O}
${emailAddress}
${L}
${ST}
${C}
${CN}
EOF
check $?
}

function make_bundle()
{
	make_csr
	make_crt
	make_pfx
	make_jks
	make_der
}

function move_to_provision()
{
	## Organization
	mkdir ../provision/$fold_name
	mv csr/$new_csr ../provision/$fold_name
	mv crt/$new_crt ../provision/$fold_name
	mv pfx/$new_pfx ../provision/$fold_name
	mv jks/$new_jks ../provision/$fold_name
	mv der/$new_der ../provision/$fold_name
}


## Main
validator
cd $root
clear
echo "------------------------------------"
echo "------- Masive Cert Creator --------"
echo "------------------------------------"
echo ""
for i in `seq $start $finish`
do
	name_definition $i
	cert_details $name
	echo "------------------------------------"
	echo "Cert bundle: $name"
	make_bundle
	echo "Done Correctly"
	echo "------------------------------------"
	move_to_provision
	echo "Organization Certs path: "$base_dir/provision/$fold_name
	echo "------------------------------------"
	echo ""
	sleep 1
done
