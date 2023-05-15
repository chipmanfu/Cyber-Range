;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.glassdoor.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.glassdoor.com.
@	IN	MX	10	glassdoor.com.
@	IN	A		104.17.91.51
mail	IN	A		104.17.91.51
www	IN	A		104.17.91.51
ns1	IN	A		198.41.0.4
