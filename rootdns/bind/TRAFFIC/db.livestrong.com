;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.livestrong.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.livestrong.com.
@	IN	MX	10	livestrong.com.
@	IN	A		104.98.88.228
mail	IN	A		104.98.88.228
www	IN	A		104.98.88.228
ns1	IN	A		198.41.0.4
