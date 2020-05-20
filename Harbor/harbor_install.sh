sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
wget https://storage.googleapis.com/harbor-releases/release-2.0.0/harbor-offline-installer-v2.0.0.tgz
tar xzvf harbor-offline-installer-v2.0.0.tgz 
cd harbor


echo "CREATE SELF SIGN CERT"
echo "---------------------"
# -newkey rsa:4096 - Creates a new certificate request and 4096 bit RSA key. The default one is 2048 bits.
# -x509 - Creates a X.509 Certificate.
# -sha256 - Use 265-bit SHA (Secure Hash Algorithm).
# -days 60 - The number of days to certify the certificate for. 3650 is 10 years. You can use any positive integer.
# -nodes - Creates a key without a passphrase.
# -out ca.crt - Specifies the filename to write the newly created certificate to. You can specify any file name.
# -keyout ca.key - Specifies the filename to write the newly created private key to. You can specify any file name.
openssl req -newkey rsa:4096 -nodes -sha256 -keyout ca.key -x509 -days 600  -out ca.crt
echo "========="


echo "CREATE SIGNING REQUEST"
echo "----------------------"
openssl req -newkey rsa:4096 -nodes -sha256 -keyout harbor.crt -out harbor.crt

echo "subjectAltName = IP:192.168.50.11" > extfile.conf
openssl x509 -req -days 60 -in harbor.crt -CA ca.crt -CAkey ca.key -CAcreateserial -extfile extfile.conf -out harbor.pem

sudo mv ca.crt ca.key /etc/ssl/certs/
sed '1,20 s/^hostname.*/hostname: 192.168.50.11/' ./harbor.yml.tmpl > ./harbor.yml
sed -i '1,20 s/80/8080/' harbor.yml
sed -i '1,20 s/^.*certificate.*/  certificate: \/etc\/ssl\/certs\/ca.crt/' harbor.yml
sed -i '1,20 s/^.*private_key.*/  private_key: \/etc\/ssl\/certs\/ca.key/' harbor.yml
sudo ./install.sh --with-clair --with-trivy --with-chartmuseum

