;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.tacticalgear.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.tacticalgear.com.
@	IN	MX	10	tacticalgear.com.
@	IN	A		172.66.43.154
mail	IN	A		172.66.43.154
www	IN	A		172.66.43.154
ns1	IN	A		198.41.0.4
