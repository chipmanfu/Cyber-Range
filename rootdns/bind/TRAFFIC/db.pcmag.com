;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.pcmag.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.pcmag.com.
@	IN	MX	10	pcmag.com.
@	IN	A		104.17.101.99
mail	IN	A		104.17.101.99
www	IN	A		104.17.101.99
ns1	IN	A		198.41.0.4
