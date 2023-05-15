;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.businesswire.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.businesswire.com.
@	IN	MX	10	businesswire.com.
@	IN	A		104.98.77.89
mail	IN	A		104.98.77.89
www	IN	A		104.98.77.89
ns1	IN	A		198.41.0.4
