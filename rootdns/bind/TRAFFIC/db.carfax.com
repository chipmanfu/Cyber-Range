;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.carfax.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.carfax.com.
@	IN	MX	10	carfax.com.
@	IN	A		13.249.85.108
mail	IN	A		13.249.85.108
www	IN	A		13.249.85.108
ns1	IN	A		198.41.0.4
