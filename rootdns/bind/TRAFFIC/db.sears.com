;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.sears.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.sears.com.
@	IN	MX	10	sears.com.
@	IN	A		23.35.132.153
mail	IN	A		23.35.132.153
www	IN	A		23.35.132.153
ns1	IN	A		198.41.0.4
