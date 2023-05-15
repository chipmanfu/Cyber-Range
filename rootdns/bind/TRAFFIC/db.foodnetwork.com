;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.foodnetwork.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.foodnetwork.com.
@	IN	MX	10	foodnetwork.com.
@	IN	A		23.194.148.29
mail	IN	A		23.194.148.29
www	IN	A		23.194.148.29
ns1	IN	A		198.41.0.4
