;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.picclick.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.picclick.com.
@	IN	MX	10	picclick.com.
@	IN	A		54.176.32.72
mail	IN	A		54.176.32.72
www	IN	A		54.176.32.72
ns1	IN	A		198.41.0.4
