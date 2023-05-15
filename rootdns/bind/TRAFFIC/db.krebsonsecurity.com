;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.krebsonsecurity.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.krebsonsecurity.com.
@	IN	MX	10	krebsonsecurity.com.
@	IN	A		130.211.45.45
mail	IN	A		130.211.45.45
www	IN	A		130.211.45.45
ns1	IN	A		198.41.0.4
