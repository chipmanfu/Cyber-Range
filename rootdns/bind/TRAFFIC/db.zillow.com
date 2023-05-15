;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.zillow.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.zillow.com.
@	IN	MX	10	zillow.com.
@	IN	A		13.249.85.39
mail	IN	A		13.249.85.39
www	IN	A		13.249.85.39
ns1	IN	A		198.41.0.4
