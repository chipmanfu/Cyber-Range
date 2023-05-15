;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.ziprecruiter.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.ziprecruiter.com.
@	IN	MX	10	ziprecruiter.com.
@	IN	A		104.16.178.190
mail	IN	A		104.16.178.190
www	IN	A		104.16.178.190
ns1	IN	A		198.41.0.4
