;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.buzzfeed.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.buzzfeed.com.
@	IN	MX	10	buzzfeed.com.
@	IN	A		151.101.194.114
mail	IN	A		151.101.194.114
www	IN	A		151.101.194.114
ns1	IN	A		198.41.0.4
