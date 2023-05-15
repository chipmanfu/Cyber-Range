;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.zoominfo.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.zoominfo.com.
@	IN	MX	10	zoominfo.com.
@	IN	A		104.16.168.82
mail	IN	A		104.16.168.82
www	IN	A		104.16.168.82
ns1	IN	A		198.41.0.4
