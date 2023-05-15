;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.cars.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.cars.com.
@	IN	MX	10	cars.com.
@	IN	A		96.17.79.248
mail	IN	A		96.17.79.248
www	IN	A		96.17.79.248
ns1	IN	A		198.41.0.4
