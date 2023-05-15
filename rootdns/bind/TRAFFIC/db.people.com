;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.people.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.people.com.
@	IN	MX	10	people.com.
@	IN	A		151.101.194.137
mail	IN	A		151.101.194.137
www	IN	A		151.101.194.137
ns1	IN	A		198.41.0.4
