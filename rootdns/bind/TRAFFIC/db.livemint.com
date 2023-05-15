;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.livemint.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.livemint.com.
@	IN	MX	10	livemint.com.
@	IN	A		23.34.76.129
mail	IN	A		23.34.76.129
www	IN	A		23.34.76.129
ns1	IN	A		198.41.0.4
