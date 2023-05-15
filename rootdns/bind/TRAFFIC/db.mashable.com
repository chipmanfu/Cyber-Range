;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.mashable.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.mashable.com.
@	IN	MX	10	mashable.com.
@	IN	A		104.18.13.9
mail	IN	A		104.18.13.9
www	IN	A		104.18.13.9
ns1	IN	A		198.41.0.4
