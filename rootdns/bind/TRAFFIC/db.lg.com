;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.lg.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.lg.com.
@	IN	MX	10	lg.com.
@	IN	A		23.35.131.241
mail	IN	A		23.35.131.241
www	IN	A		23.35.131.241
ns1	IN	A		198.41.0.4
