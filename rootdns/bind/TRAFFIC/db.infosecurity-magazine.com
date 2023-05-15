;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.infosecurity-magazine.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.infosecurity-magazine.com.
@	IN	MX	10	infosecurity-magazine.com.
@	IN	A		13.249.85.109
mail	IN	A		13.249.85.109
www	IN	A		13.249.85.109
ns1	IN	A		198.41.0.4
