;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.dailymotion.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.dailymotion.com.
@	IN	MX	10	dailymotion.com.
@	IN	A		198.54.201.90
mail	IN	A		198.54.201.90
www	IN	A		198.54.201.90
ns1	IN	A		198.41.0.4
