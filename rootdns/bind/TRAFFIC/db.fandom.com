;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.fandom.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.fandom.com.
@	IN	MX	10	fandom.com.
@	IN	A		199.232.212.194
mail	IN	A		199.232.212.194
www	IN	A		199.232.212.194
ns1	IN	A		198.41.0.4
