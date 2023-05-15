;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.dreamstime.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.dreamstime.com.
@	IN	MX	10	dreamstime.com.
@	IN	A		169.62.154.245
mail	IN	A		169.62.154.245
www	IN	A		169.62.154.245
ns1	IN	A		198.41.0.4
