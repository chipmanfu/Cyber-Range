;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.android.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.android.com.
@	IN	MX	10	android.com.
@	IN	A		142.250.190.142
mail	IN	A		142.250.190.142
www	IN	A		142.250.190.142
ns1	IN	A		198.41.0.4
