# conjur-quickstart
This repository is coupled to documentation tutorial https://www.conjur.org/get-started which guides you through the Conjur deployment of securely fetching a secret with a proprietary demo app.

For additional security layer, we reccomend supplying a SSL server certificate and a key by your organization, which are not self-signed.

Name your organization certificate and key to <code>nginx.crt</code> & <code>nginx.key</code> respectively copy them to the following directory: <code>conf/certificate</code>

Follow our mandatory structure listed at our documentation
https://docs.cyberark.com/Deployment/HighAvailability/certificate-requirements.htm 

See example for certificate structure at <code>conf/tls.conf</code>

[Not recommend] To run the quickstart using a self-signed certificate, replace the tutorial command:

<code>docker-compose up -d</code>

With following line:

<code>docker-compose -f docker-compose.yml -f docker-compose.selfsigned.yml up -d</code>
