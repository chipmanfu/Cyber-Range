;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.tripadvisor.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.tripadvisor.com.
@	IN	MX	10	tripadvisor.com.
@	IN	A		23.78.9.97
mail	IN	A		23.78.9.97
www	IN	A		23.78.9.97
ns1	IN	A		198.41.0.4
