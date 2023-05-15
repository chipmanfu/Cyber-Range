;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.deadline.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.deadline.com.
@	IN	MX	10	deadline.com.
@	IN	A		192.0.66.32
mail	IN	A		192.0.66.32
www	IN	A		192.0.66.32
ns1	IN	A		198.41.0.4
