;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.salary.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.salary.com.
@	IN	MX	10	salary.com.
@	IN	A		45.78.159.143
mail	IN	A		45.78.159.143
www	IN	A		45.78.159.143
ns1	IN	A		198.41.0.4
