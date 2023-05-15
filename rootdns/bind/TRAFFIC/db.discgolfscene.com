;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.discgolfscene.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.discgolfscene.com.
@	IN	MX	10	discgolfscene.com.
@	IN	A		104.26.5.249
mail	IN	A		104.26.5.249
www	IN	A		104.26.5.249
ns1	IN	A		198.41.0.4
