# conjur-quickstart
This repository is coupled to documentation tutorial https://www.conjur.org/get-started

Which guides you through Conjur deployment to fetching a secret with a supplied demo app.

For additional security layer, we are defaulting to deploying quickstart with 3rd party certificate.
Supply your organization certificate and key named accordingly <code>nginx.crt</code> & <code>nginx.key</code> to the following directory <code>conf/certificate</code>

Follow our mandatory structure listed at our documentation
https://docs.cyberark.com/Deployment/HighAvailability/certificate-requirements.htm 

See example for certificate structure at <code>conf/tls.conf</code>

To run Quickstart in an unsecured manner, using a self signed certificate, replace command:

<code>docker-compose up -d</code>

With following line:

<code>docker-compose -f docker-compose.yml -f docker-compose.selfsigned.yml up -d</code>
