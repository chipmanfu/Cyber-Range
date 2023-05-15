;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.untappd.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.untappd.com.
@	IN	MX	10	untappd.com.
@	IN	A		104.26.13.22
mail	IN	A		104.26.13.22
www	IN	A		104.26.13.22
ns1	IN	A		198.41.0.4
