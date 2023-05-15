;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.starbucks.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.starbucks.com.
@	IN	MX	10	starbucks.com.
@	IN	A		23.35.137.227
mail	IN	A		23.35.137.227
www	IN	A		23.35.137.227
ns1	IN	A		198.41.0.4
