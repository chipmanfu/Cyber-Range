;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.songkick.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.songkick.com.
@	IN	MX	10	songkick.com.
@	IN	A		151.101.194.217
mail	IN	A		151.101.194.217
www	IN	A		151.101.194.217
ns1	IN	A		198.41.0.4
