;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.cnbc.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.cnbc.com.
@	IN	MX	10	cnbc.com.
@	IN	A		96.17.52.124
mail	IN	A		96.17.52.124
www	IN	A		96.17.52.124
ns1	IN	A		198.41.0.4
