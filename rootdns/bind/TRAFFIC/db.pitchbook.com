;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.pitchbook.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.pitchbook.com.
@	IN	MX	10	pitchbook.com.
@	IN	A		34.110.234.203
mail	IN	A		34.110.234.203
www	IN	A		34.110.234.203
ns1	IN	A		198.41.0.4
