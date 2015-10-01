# vagrant-sensu

Provides a sensu server, a sensu client, and a webserver running uchiwa (sensu dashboard)

## usage:
To provision the VMs:  
`vagrant up`

Once the VMs are up and running they are defined as:  

### Sensu server
* ip-address  10.254.254.10
* hostname  sensu-server
* vagrant ssh sensu_server

### Sensu client
* ip-address 10.254.254.11
* hostname sensu-client
* vagrant ssh sensu_client

### Sensu Dashboard (webserver)
* ip-address  10.254.254.12
* hostname  web-server
* vagrant ssh web_server

## Webpages available are:
* uchiwa - the sensu dashboard at: http://10.254.254.12:3000
* rabbitmq - management page at: http://10.254.254.10:15672  
login as admin, password is admin (defined in hiera)
* flapjack - the notification router at http://10.254.254.10:3080


## References:

* http://sensuapp.org
* http://flapjack.io
* http://www.rabbitmq.com

## NOTES - things discovered
There is a reference to templates for messages send in th e/etc/flapjack/flapjack_config.yaml file:
 ** location of custom alert templates
  * rollup_subject.text: '/etc/flapjack/templates/email/rollup_subject.text.erb'
  * alert_subject.text: '/etc/flapjack/templates/email/alert_subject.text.erb'
  * rollup.text: '/etc/flapjack/templates/email/rollup.text.erb'
  * alert.text: '/etc/flapjack/templates/email/alert.text.erb'
  * rollup.html: '/etc/flapjack/templates/email/rollup.html.erb'
  * alert.html: '/etc/flapjack/templates/email/alert.html.erb'

The original versions of these as well as other ones can be found in:  
/opt/flapjack/embedded/lib/ruby/gems/2.1.0/gems/flapjack-1.5.0/lib/flapjack/gateways


