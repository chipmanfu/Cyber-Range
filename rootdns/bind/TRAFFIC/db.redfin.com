;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.redfin.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.redfin.com.
@	IN	MX	10	redfin.com.
@	IN	A		23.11.224.205
mail	IN	A		23.11.224.205
www	IN	A		23.11.224.205
ns1	IN	A		198.41.0.4
