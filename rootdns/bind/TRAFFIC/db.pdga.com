;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.pdga.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.pdga.com.
@	IN	MX	10	pdga.com.
@	IN	A		172.66.40.249
mail	IN	A		172.66.40.249
www	IN	A		172.66.40.249
ns1	IN	A		198.41.0.4
