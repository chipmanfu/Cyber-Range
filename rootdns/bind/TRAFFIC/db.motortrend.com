;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.motortrend.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.motortrend.com.
@	IN	MX	10	motortrend.com.
@	IN	A		23.220.144.142
mail	IN	A		23.220.144.142
www	IN	A		23.220.144.142
ns1	IN	A		198.41.0.4
