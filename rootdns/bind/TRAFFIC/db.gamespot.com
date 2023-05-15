;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.gamespot.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.gamespot.com.
@	IN	MX	10	gamespot.com.
@	IN	A		199.232.212.194
mail	IN	A		199.232.212.194
www	IN	A		199.232.212.194
ns1	IN	A		198.41.0.4
