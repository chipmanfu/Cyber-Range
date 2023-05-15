;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.superuser.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.superuser.com.
@	IN	MX	10	superuser.com.
@	IN	A		151.101.129.69
mail	IN	A		151.101.129.69
www	IN	A		151.101.129.69
ns1	IN	A		198.41.0.4
