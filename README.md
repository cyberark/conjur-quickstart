# conjur-quickstart
This repository is coupled to documentation tutorial https://www.conjur.org/get-started

Which guides you through Conjur deployment of securely fetching a secret with a proprietary demo app.

For additional security layer, we are requiring supplying SSL server certificate and key by your organization, which are not self-signed.

Your organization certificate and key should be named <code>nginx.crt</code> & <code>nginx.key</code> accordingly and required to be placed at the following directory <code>conf/certificate</code>

Follow our mandatory structure listed at our documentation
https://docs.cyberark.com/Deployment/HighAvailability/certificate-requirements.htm 

See example for certificate structure at <code>conf/tls.conf</code>

[Not recommend] To run quickstart using a self-signed certificate, replace tutorial command:

<code>docker-compose up -d</code>

With following line:

<code>docker-compose -f docker-compose.yml -f docker-compose.selfsigned.yml up -d</code>
