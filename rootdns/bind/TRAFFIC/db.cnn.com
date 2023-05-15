;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.cnn.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.cnn.com.
@	IN	MX	10	cnn.com.
@	IN	A		151.101.195.5
mail	IN	A		151.101.195.5
www	IN	A		151.101.195.5
ns1	IN	A		198.41.0.4
