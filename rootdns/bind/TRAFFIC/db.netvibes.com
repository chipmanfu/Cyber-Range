;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.netvibes.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.netvibes.com.
@	IN	MX	10	netvibes.com.
@	IN	A		193.189.143.34
mail	IN	A		193.189.143.34
www	IN	A		193.189.143.34
ns1	IN	A		198.41.0.4
