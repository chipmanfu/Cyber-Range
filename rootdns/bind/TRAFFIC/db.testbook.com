;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.testbook.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.testbook.com.
@	IN	MX	10	testbook.com.
@	IN	A		35.244.145.245
mail	IN	A		35.244.145.245
www	IN	A		35.244.145.245
ns1	IN	A		198.41.0.4
