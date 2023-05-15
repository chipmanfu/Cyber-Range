;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.howstuffworks.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.howstuffworks.com.
@	IN	MX	10	howstuffworks.com.
@	IN	A		13.249.85.117
mail	IN	A		13.249.85.117
www	IN	A		13.249.85.117
ns1	IN	A		198.41.0.4
