;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.drugs.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.drugs.com.
@	IN	MX	10	drugs.com.
@	IN	A		23.2.91.170
mail	IN	A		23.2.91.170
www	IN	A		23.2.91.170
ns1	IN	A		198.41.0.4
