;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.weather.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.weather.com.
@	IN	MX	10	weather.com.
@	IN	A		96.17.53.167
mail	IN	A		96.17.53.167
www	IN	A		96.17.53.167
ns1	IN	A		198.41.0.4
