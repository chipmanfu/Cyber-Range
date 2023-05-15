;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.foursquare.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.foursquare.com.
@	IN	MX	10	foursquare.com.
@	IN	A		151.101.194.132
mail	IN	A		151.101.194.132
www	IN	A		151.101.194.132
ns1	IN	A		198.41.0.4
