;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.fandango.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.fandango.com.
@	IN	MX	10	fandango.com.
@	IN	A		23.194.146.79
mail	IN	A		23.194.146.79
www	IN	A		23.194.146.79
ns1	IN	A		198.41.0.4
