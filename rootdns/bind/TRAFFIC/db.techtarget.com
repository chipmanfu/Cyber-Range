;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.techtarget.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.techtarget.com.
@	IN	MX	10	techtarget.com.
@	IN	A		104.18.13.159
mail	IN	A		104.18.13.159
www	IN	A		104.18.13.159
ns1	IN	A		198.41.0.4
