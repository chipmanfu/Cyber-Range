;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.airbnb.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.airbnb.com.
@	IN	MX	10	airbnb.com.
@	IN	A		23.220.144.148
mail	IN	A		23.220.144.148
www	IN	A		23.220.144.148
ns1	IN	A		198.41.0.4
